# AMPP 

AMPP (**A**pache, **M**ariaDB, **P**HP per **P**roject) is Windows utility to configure and run Apache (with PHP), MySQL/MariaDB instances per each project.
So you have configuration files in the project directory and run stand-alone servers only when developing (like Meteor).

## Requirements
- Apache 2.4 in `C:\Apache24`
- MariaDB in `C:\MariaDB`
- PHP 5.6 in `C:\PHP56`

`PATH` environment variable must be set up for each requirement 

## Installation

Download [install.ps1](https://github.com/uiii/ampp/blob/master/install.ps1) script and run in the PowerShell.

Or run this command in `Cmd.exe` (run as Administrator):
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/uiii/ampp/master/install.ps1'))"
```

## Usage

1. Create project directory:
	```
	ampp -create <directory> 
	```
2. write code ...
3. run AMPP
	```
	cd <directory>
	ampp
	```
4. visit `localhost:8000`

## Command line options

`-create <directory>`: Create a project directory with specified name and initialize AMPP project inside  
`-port <port>`: Run Apache on specified port, MariaDB will run on the port increased by 1
