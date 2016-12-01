param(
	[Parameter(Mandatory=$false)]
	[string] $create,

	[switch] $init,

	[Parameter(Mandatory=$false)]
	[int] $port = 8000,

	[switch] $version
)

. $PSScriptRoot\..\functions\new.ps1
. $PSScriptRoot\..\functions\start.ps1

if ($create) {
	New-Ampp -Name $create
} elseif ($init.IsPresent) {
	Initialize-Ampp (Get-Location)
} elseif ($version.IsPresent) {
	(Get-Content $PSScriptRoot\..\.version).Split("@")[1]
} else {
	Start-Ampp -Port $port
}