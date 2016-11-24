function Start-Ampp
{
	[int] $port = 8000

	$amppDir = Join-Path (Get-Location) ".ampp"
	$mysqlPort = $port + 1

	if (-Not (Test-Path $amppDir)) {
		"$(Get-Location): There is no AMPP project in this directory"
		return
	}

	$apacheConfPath = Join-Path $amppDir "apache\httpd.conf"
	$mysqlConf = Join-Path $amppDir "mariadb\my.ini"

	"Starting MariaDB database on port $mysqlPort"
	Start-Process mysqld -ArgumentList "--defaults-file=$mysqlConf","--port=$mysqlPort" -WindowStyle Hidden

	"Starting Apache HTTP server on port $port"
	$apache = Start-Process httpd -ArgumentList "-f","$apacheConfPath","-c","""Listen $port""" -WindowStyle Hidden -PassThru

	WaitForCtrlC

	# start servers
	"`nStopping Apache HTTP server"
	Stop-Process -Id $apache.Id

	"Stopping MariaDB database"
	mysqladmin.exe -u root --port=$mysqlPort shutdown
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