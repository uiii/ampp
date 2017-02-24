. $PSScriptRoot\..\functions\helpers.ps1

function Start-Ampp
{
	param(
		[int] $port = 8000,
		[int] $mysqlPort = $port + 1
	)

	$projectDir = Get-Location
	$amppDir = Join-Path $projectDir ".ampp"
	$amppTmpDir = Join-Path $amppDir ".tmp"

	if (-Not (Test-Path $amppDir)) {
		"$(Get-Location): There is no AMPP project in this directory"
		return
	}

	if (-Not (Test-Path $amppTmpDir)) {
		New-Item -ItemType Directory -Path $amppTmpDir | Out-Null
	}

	$phpVersion = Get-Content -Path (Join-Path $amppDir "php\version")

	# Search paths
	Write-Host -NoNewline "Searching Apache installation ... "
	$apacheInstallDir = Find-Apache
	"found in $apacheInstallDir"

	Write-Host -NoNewline "Searching MariaDB installation ... "
	$mariaDBInstallDir = Find-MariaDB
	"found in $mariaDBInstallDir"

	Write-Host -NoNewline "Searching PHP $phpVersion installation ... "
	$phpInstallDir = Find-PHP -version $phpVersion
	"found in $phpInstallDir"

	"NOTE: To change these paths edit file " + [System.IO.Path]::GetFullPath((Join-Path $cahceDir 'paths')) + "`n"

	# Expand config files
	$APACHE_ROOT = $apacheInstallDir
	$MYSQL_ROOT = $mariaDBInstallDir
	$PHP_ROOT = $phpInstallDir

	$AMPP_APACHE_LOG_DIR = (Join-Path $amppDir "apache")
	$AMPP_APACHE_PHP_CONF = (Join-Path $amppTmpDir "apache\mod_php.conf")
	$AMPP_PHP_INI_DIR = (Join-Path $amppTmpDir "php")
	$AMPP_MYSQL_DATA_DIR = (Join-Path $amppDir "mariadb\data").Replace("\", "/")

	$DOCUMENT_ROOT = $projectDir

	Expand-Conf -Path (Join-Path $amppDir "apache\httpd.conf") -Destination (Join-Path $amppTmpDir "apache\httpd.conf")
	Expand-Conf -Path (Join-Path $amppDir "apache\mod_php.conf") -Destination (Join-Path $amppTmpDir "apache\mod_php.conf")
	Expand-Conf -Path (Join-Path $amppDir "php\php.ini") -Destination (Join-Path $amppTmpDir "php\php.ini")
	Expand-Conf -Path (Join-Path $amppDir "mariadb\my.ini") -Destination (Join-Path $amppTmpDir "mariadb\my.ini")

	# Initialize MariaDB if needed
	if (-Not (Test-Path $AMPP_MYSQL_DATA_DIR) -Or -Not (Get-ChildItem $AMPP_MYSQL_DATA_DIR | Measure-Object).count) {
		"Initializing MariaDB data"
		& $MYSQL_ROOT\bin\mysql_install_db --datadir=$AMPP_MYSQL_DATA_DIR | Out-Null
		""
	}

	# Check if ports are available
	if (Get-NetTCPConnection -LocalPort $port -ErrorAction Ignore) {
		throw "Some process is already listening on port $mysqlPort"
	}

	if (Get-NetTCPConnection -LocalPort $mysqlPort -ErrorAction Ignore) {
		throw "Some process is already listening on port $mysqlPort"
	}

	# Start servers
	"Starting MariaDB database on port $mysqlPort"
	Start-Process $MYSQL_ROOT\bin\mysqld.exe -ArgumentList "--defaults-file=$(Join-Path $amppTmpDir "mariadb\my.ini")","--port=$mysqlPort" -WindowStyle Hidden

	"Starting Apache HTTP server on port $port"
	$apache = Start-Process $APACHE_ROOT\bin\httpd.exe -ArgumentList "-f",(Join-Path $amppTmpDir "apache\httpd.conf"),"-c","""Listen $port""" -WindowStyle Hidden -PassThru

	WaitForCtrlC

	# Stop servers
	"`nStopping Apache HTTP server"
	Stop-Process -Id $apache.Id

	"Stopping MariaDB database"
	& $MYSQL_ROOT\bin\mysqladmin.exe -u root --port=$mysqlPort shutdown
}

function WaitForCtrlC
{
	[System.Console]::TreatControlCAsInput = $true

	do {
		"`nPress Ctrl+C to stop"
		$key = [System.Console]::ReadKey($true)
	} while (($key.Modifiers -ne [System.ConsoleModifiers]::Control) -or ($key.key -ne "C"))

	[System.Console]::TreatControlCAsInput = $false
}