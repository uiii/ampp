. $PSScriptRoot\..\functions\helpers.ps1

$filesDir = (Join-Path $PSScriptRoot "../default")
$cahceDir = (Join-Path $PSScriptRoot "../.cache")

function New-Ampp
{
	param(
		[parameter(Mandatory=$false)]
		[string] $phpVersion = "7",

		[string] $name
	)

	$projectDir = Join-Path (Get-Location) $name

	if (Test-Path $projectDir) {
		$projectDir + ": Directory already exists"
		return
	}

	New-Item -ItemType Directory -Path $projectDir | Out-Null

	Initialize-Ampp -PhpVersion $phpVersion $projectDir

	# setup project inital files
	Copy-Item -Path (Join-Path $filesDir "index.php") -Destination $projectDir
}

function Initialize-Ampp
{
	param(
		[parameter(Mandatory=$false)]
		[string] $phpVersion = "7",

		[string] $projectDir

	)

	Write-Host -NoNewline "Initializing AMPP ... "

	# create AMPP directory
	$projectAmppDir = Join-Path $projectDir ".ampp"

	if (Test-Path $projectAmppDir) {
		$projectAmppDir + ": AMPP already initialized"
		return
	}

	New-Item -ItemType Directory -Path $projectAmppDir | Out-Null

	# setup Apache & PHP
	$amppApacheDir = (Join-Path $projectAmppDir "apache")
	$amppPHPDir = (Join-Path $projectAmppDir "php")

	New-Item -ItemType Directory -Path $amppApacheDir | Out-Null
	New-Item -ItemType Directory -Path $amppPHPDir | Out-Null

	Copy-Item -Path (Join-Path $filesDir "apache\httpd.conf") -Destination (Join-Path $amppApacheDir "httpd.conf")
	Copy-Item -Path (Join-Path $filesDir "apache\mod_php$phpVersion.conf") -Destination (Join-Path $amppApacheDir "mod_php.conf")
	Copy-Item -Path (Join-Path $filesDir "php\php$phpVersion.ini") -Destination (Join-Path $amppPHPDir "php.ini")

	$phpVersion | Out-File (Join-Path $amppPHPDir 'version')

	# setup MySQL
	$amppMysqlDir = (Join-Path $projectAmppDir "mariadb")
	$amppMysqlDataDir = (Join-Path $amppMysqlDir "data")

	New-Item -ItemType Directory -Path $amppMysqlDir | Out-Null
	New-Item -ItemType Directory -Path $amppMysqlDataDir | Out-Null

	Copy-Item -Path (Join-Path $filesDir "mariadb\mariadb.ini") -Destination (Join-Path $amppMysqlDir "my.ini")

	# setup .gitignore
	Copy-Item -Path (Join-Path $filesDir "gitignore") -Destination (Join-Path $projectAmppDir ".gitignore")

	"Done"
}