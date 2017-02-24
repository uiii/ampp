param(
	[switch] $version,

	[switch] $init,

	[switch] $create,

	[Parameter(Mandatory=$false)]
	[string] $name,

	[Parameter(Mandatory=$false)]
	[int] $port = 8000,

	[Parameter(Mandatory=$false)]
	[int] $phpVersion = 7
)

. $PSScriptRoot\..\functions\new.ps1
. $PSScriptRoot\..\functions\start.ps1

if ($create.IsPresent) {
	New-Ampp -Name $name -PhpVersion $phpVersion
} elseif ($init.IsPresent) {
	Initialize-Ampp -PhpVersion $phpVersion (Get-Location)
} elseif ($version.IsPresent) {
	(Get-Content $PSScriptRoot\..\.version).Split("@")[1]
} else {
	Start-Ampp -Port $port
}