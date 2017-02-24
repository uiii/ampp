# AMPP

AMPP (**A**pache, **M**ariaDB, **P**HP per **P**roject) is Windows utility to configure and run Apache (with PHP), MySQL/MariaDB instances per each project.
So you have configuration files in the project directory and run stand-alone servers only when developing (like Meteor).

## Requirements
- Apache 2.4
- MariaDB
- PHP 5.6+

## Installation

> AMPP is installed only for the **current user** in the `%LOCALAPPDATA%\ampp` directory

Download [install.ps1](https://github.com/uiii/ampp/blob/master/install.ps1) script and run it in the PowerShell.

Or run this command in `Cmd.exe`:
```
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/uiii/ampp/master/install.ps1'))"
```

## Paths

AMPP will find all (search all hard drives) required application's installation paths on the first start.
If you want to specify the paths manually, put it in the file `%LOCALAPPDATA%\ampp\.cache\paths` in format `<application-key>|<installation-path>`.
Available *application keys* are: `apache`, `mariadb`, `php5`, `php7`.

For e.g.
```
apache|C:\tools\Apache\httpd-2.4.20\Apache24
mariadb|C:\Program Files\MariaDB 10.1
php7|C:\tools\php71
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

`-start`: Start AMPP in the current directory
`-init`: Initialize AMPP project in the current directory
`-create`: Create a project directory with name specified by `-name` parameter and initialize AMPP project inside
`-name <name>`: Used with `-create` option
`-port <port>`: Run Apache on specified port, MariaDB will run on the port increased by 1
`-phpVersion <version>`: Use specific PHP version (available: 5, 7)

## Default configurations

In the `%LOCALAPPDATA%\ampp\default` directory are default configuration files.
It is safe to edit them to change the defaults.

> Be careful with the variables starting with `$` (e.g. `$DOCUMENT_ROOT`),
> these are replaced by the proper paths when creating new project.
