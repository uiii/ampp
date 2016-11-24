param(
	[Parameter(Mandatory=$false)]
	[string] $create,

	[Parameter(Mandatory=$false)]
	[int] $port = 8000
)

. $PSScriptRoot\..\functions\new.ps1
. $PSScriptRoot\..\functions\start.ps1

if ($create) {
	New-Ampp -Name $create
} else {
	Start-Ampp -Port $port
}