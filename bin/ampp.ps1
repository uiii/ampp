param(
	[Parameter(Mandatory=$false)]
	[string] $create,

	[switch] $init,

	[Parameter(Mandatory=$false)]
	[int] $port = 8000
)

. $PSScriptRoot\..\functions\new.ps1
. $PSScriptRoot\..\functions\start.ps1

if ($create) {
	New-Ampp -Name $create
} elseif ($init.IsPresent) {
	Initialize-Lamp (Get-Location)
} else {
	Start-Ampp -Port $port
}