$filesDir = (Join-Path $PSScriptRoot "../files")

function New-Ampp
{
	param(
		[string] $name
	)

	$projectDir = Join-Path (Get-Location) $name
	$projectAmppDir = Join-Path $projectDir ".ampp"

	if (Test-Path $projectDir) {
		$projectDir + ": the path is not empty"
		return
	}

	New-Item -ItemType Directory -Path $projectDir
	New-Item -ItemType Directory -Path $projectAmppDir

	# setup Apache & PHP
	$amppApacheDir = (Join-Path $projectAmppDir "apache")
	$amppPHPDir = (Join-Path $projectAmppDir "php")

	New-Item -ItemType Directory -Path $amppApacheDir
	New-Item -ItemType Directory -Path $amppPHPDir

	$AMPP_APACHE_ROOT = $amppApacheDir
	$AMPP_PHP_ROOT = $amppPHPDir
	$DOCUMENT_ROOT = $projectDir

	Expand-Conf -Path (Join-Path $filesDir "httpd.conf") -Destination (Join-Path $amppApacheDir "httpd.conf")
	Expand-Conf -Path (Join-Path $filesDir "mod_php.conf") -Destination (Join-Path $amppApacheDir "mod_php.conf")
	Copy-Item -Path (Join-Path $filesDir "php56.ini") -Destination (Join-Path $amppPHPDir "php.ini")

	# setup MySQL
	$amppMysqlDir = (Join-Path $projectAmppDir "mariadb")
	$amppMysqlDataDir = (Join-Path $amppMysqlDir "data")

	New-Item -ItemType Directory -Path $amppMysqlDir
	New-Item -ItemType Directory -Path $amppMysqlDataDir

	$AMPP_MYSQL_ROOT = $amppMysqlDir.Replace("\", "/")

	Expand-Conf -Path (Join-Path $filesDir "mariadb.ini") -Destination (Join-Path $amppMysqlDir "my.ini")

	mysql_install_db --datadir=$amppMysqlDataDir

	# setup .gitignore
	Copy-Item -Path (Join-Path $filesDir "gitignore") -Destination (Join-Path $projectAmppDir ".gitignore")

	# setup project inital files
	Copy-Item -Path (Join-Path $filesDir "index.php") -Destination $projectDir
}

function Expand-Conf
{
	param(
		[string] $path,
		[string] $destination
	)

	$lines = New-Object System.Collections.ArrayList

	foreach ($line in (Get-Content $path)) {
		$lines.Add($ExecutionContext.InvokeCommand.ExpandString($line)) | Out-Null
	}

	[System.IO.File]::WriteAllLines($destination, $lines)
}