param(
	[string] $installDir = "C:\Program Files\ampp",
	[switch] $force
)

$url = "https://github.com/uiii/ampp/archive/master.zip"

if ((Test-Path $installDir) -And -Not $force.IsPresent) {
	$installDir + ": Install dir is not empty, AMPP is probably installed, skipping (use -Force to overwrite it)."
	return
}

$tmpFile = New-TemporaryFile

$zipFile = $tmpFile.FullName + '.zip'
$extractDir = $tmpFile.FullName + ".extract"

# download zip
$tmpFile.MoveTo($zipFile)
Invoke-WebRequest -Uri $url -OutFile $zipFile

# extract
Expand-Archive -LiteralPath $zipFile -DestinationPath $extractDir

# create install directory
New-Item -ItemType Directory -Force $installDir

$items = Get-ChildItem -Path (Join-Path $extractDir "ampp-master\*")

foreach ($item in $items) {
	Copy-Item -LiteralPath $item -Destination $installDir -Recurse
}

# clean
Remove-Item -LiteralPath $zipFile
Remove-Item -LiteralPath $extractDir

# set PATH
$binPath = Join-Path $installDir "bin"

$environmentPath = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").Path

if (-Not $environmentPath.ToLower().Contains($binPath.ToLower())) {
	$environmentPath = "$environmentPath;$binPath"
}

setx /m PATH $environmentPath