$cacheDir = (Join-Path $PSScriptRoot "../.cache")

function Find-File
{
	param (
		[string] $name,

		[parameter(Mandatory=$false)]
		[array] $directories
	)

	if (! $directories) {
		$directories = (Get-PSDrive -PSProvider "FileSystem" | Select-Object -ExpandProperty "Root")
	}

	$found = @()

	foreach ($directory in $directories) {
		$files = Get-ChildItem -LiteralPath $directory -Recurse -Filter $name -ErrorAction SilentlyContinue
		$found = $found + $files
	}

	return $found
}

function Get-Cache
{
	param (
		[string] $file,
		[string] $key
	)

	$cache = Get-Content -Encoding UTF8 -Path (Join-Path $cacheDir $file) -ErrorAction Ignore | ConvertFrom-Csv -Delimiter '|' -Header 'Key','Value'

	return $cache | ? { $_.Key -eq $key} | select -first 1 | select -ExpandProperty 'Value'
}

function Set-Cache
{
	param (
		[string] $file,
		[string] $key,
		[string] $value
	)

	if (-Not (Test-Path $cacheDir)) {
		New-Item -ItemType Directory -Path $cacheDir | Out-Null
	}

	$key + "|" + $value | Out-File -Append (Join-Path $cacheDir $file)
}

function Find-Apache
{
	$cached = Get-Cache -File 'paths' -Key 'apache'

	if ($cached) {
		return $cached
	}

	$executables = Find-File -name "httpd.exe"

	foreach ($executable in $executables) {
		if ($executable.Directory.Name -ne "bin") {
			continue
		}

		$output = & $executable.FullName -v 2>&1 | Out-String

		if ($output -NotMatch 'Server version: Apache') {
			continue
		}

		$path = $executable.Directory.Parent.FullName

		Set-Cache -File 'paths' -Key 'apache' -Value $path

		return $path
	}

	throw [System.IO.FileNotFoundException] "Apache installation directory wasn't found"
}

function Find-MariaDB
{
	$cached = Get-Cache -File 'paths' -Key 'mariadb'

	if ($cached) {
		return $cached
	}

	$executables = Find-File -name "mysql.exe"

	foreach ($executable in $executables) {
		if ($executable.Directory.Name -ne "bin") {
			continue
		}

		$output = & $executable.FullName -V 2>&1 | Out-String

		if ($output -NotMatch "MariaDB") {
			continue
		}

		$path = $executable.Directory.Parent.FullName

		Set-Cache -File 'paths' -Key 'mariadb' -Value $path

		return $path
	}

	throw [System.IO.FileNotFoundException] "MariaDB installation directory wasn't found"
}

function Find-PHP
{
	param (
		[string] $version
	)

	$cached = Get-Cache -File 'paths' -Key "php$version"

	if ($cached) {
		return $cached
	}

	$executables = Find-File -name "php.exe"

	foreach ($executable in $executables) {
		$output = & $executable.FullName -v 2>&1 | Out-String

		if ($output -NotMatch "PHP $version") {
			continue
		}

		if (Find-File -name "*apache2_4.dll" -directories $executable.Directory.FullName) {
			$path = $executable.Directory.FullName

			Set-Cache -File 'paths' -Key "php$version" -Value $path

			return $path
		}
	}

	throw [System.IO.FileNotFoundException] "PHP installation directory wasn't found"
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

	$destinationDir = Split-Path $destination -Parent

	if (-Not (Test-Path $destinationDir)) {
		New-Item -ItemType Directory $destinationDir | Out-Null
	}

	[System.IO.File]::WriteAllLines($destination, $lines)
}