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

# download zip
$tmpFile.MoveTo($zipFile)
Invoke-WebRequest -Uri $url -OutFile $zipFile

# create install directory
New-Item -ItemType Directory -Force $installDir

# extract
Expand-Archive -LiteralPath $zipFile -DestinationPath $installDir

# clean
Remove-Item -LiteralPath $zipFile

# set PATH
$binPath = Join-Path $installDir "bin"

$environmentPath = (Get-ItemProperty -Path Registry::"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment").Path

if (-Not $environmentPath.ToLower().Contains($binPath.ToLower())) {
	$environmentPath = "$environmentPath;$binPath"
}

setx /m PATH $environmentPath