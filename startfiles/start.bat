@echo off

:: +-------------------------------------------------------------------------
:: |
:: | WPN-XM Server Stack - Start Daemons
:: |
:: +-----------------------------------------------------------------------<3

if exist "%~dp0temp" (
    echo Removing Temporary Files...
    del /F/S/Q "%~dp0temp\" > nul
    rmdir /S/Q "%~dp0temp\"
)

if not exist "%~dp0temp" (
    echo Creating Directories for Temporary Files...
    mkdir "%~dp0temp"
)

if not exist "%~dp0logs" (
    echo Creating Directories for Logs...
    mkdir "%~dp0logs"
)

SET HIDECONSOLE=%~dp0bin\tools\RunHiddenConsole.exe

:: start all daemons, if no argument given (default)
if "%1"=="" (
    call:start-php
    call:start-mariadb
    call:start-memcached
    call:start-nginx
    call:start-browser
) else (
    :: start specific daemon
    :: where $1 is the first cli argument, e.g. "start-wpnxm.bat php"
    call:start-%1
)
goto END

:: the start functions

:start-php
    echo Starting PHP FastCGI...

    :: disable default FCGI request limit of 500
    set PHP_FCGI_MAX_REQUESTS=0
    set PHP_FCGI_CHILDREN=4

    %HIDECONSOLE% %~dp0bin\php\php-cgi.exe -b 127.0.0.1:9100 -c %~dp0bin\php\php.ini
    echo.
goto END

:start-mariadb
    echo Starting MariaDb...
    %HIDECONSOLE% %~dp0bin\mariadb\bin\mysqld.exe --defaults-file=%~dp0bin\mariadb\my.ini
    echo.
goto END

:start-memcached
    echo Starting Memcached...
    %HIDECONSOLE% %~dp0bin\memcached\memcached.exe -p 11211 -U 0 -t 2 -c 2048 -m 2048
    echo.
goto END

:start-nginx
    echo Starting nginx...
    %HIDECONSOLE% %~dp0bin\nginx\nginx.exe -p %~dp0 -c %~dp0bin\nginx\conf\nginx.conf
    echo.
goto END

:start-browser
    echo Opening localhost in Browser...
    start http://localhost/
goto END

:ERROR
pause>nul

:END