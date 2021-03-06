@echo off

Rscript --version 1> nul 2>&1
if %ERRORLEVEL% GTR 0 (
    echo ERROR: No R installation available.
    echo Please install R and verify its location added PATH environment variable.
    exit /B 1
)

set base_dir=%~dp0
set cmd="%1"

if %cmd%=="" goto help
if %cmd%=="help" goto help

if %cmd%=="install" (
    Rscript --no-init-file "%base_dir%/R/cmd_install.R" %*
    if ERRORLEVEL 1 exit /B 2
    exit /b 0
)

if %cmd%=="proj" (
    Rscript.exe --no-init-file "%base_dir%/R/cmd_proj.R" %*
    if ERRORLEVEL 1 exit /B 2
    exit /b 0
)

if %cmd%=="repo" (
    Rscript --no-init-file "%base_dir%/R/cmd_repo.R" %*
    if ERRORLEVEL 1 exit /B 2
    exit /b 0
)

if %cmd%=="pkgzip" (
    Rscript --no-init-file "%base_dir%/R/cmd_pkgzip.R" %*
    if ERRORLEVEL 1 exit /B 2
    exit /b 0
)

if %cmd%=="version" (
    type "%base_dir%/version.txt"
    exit /b 0
)

echo ERROR: Unexpected command %cmd% passed.
echo Please, call 'rsuite help' to see available commands.
exit /B 3

:help
    set /P ver=<"%base_dir%/version.txt"
    echo Command line utility for R project management with RSuite (v%ver%).
    echo Usage: rsuite [command] [args]
    echo.
    echo.
    echo Commands:
    echo        install
    echo            Install RSuite with all the dependencies.
    echo.
    echo        proj
    echo            Use it to manage project, its dependencies, and build
    echo            project packages.
    echo.
    echo        repo
    echo            Use to manage repositories. e.g. upload packages.
    echo.
    echo        pkgzip
    echo            Use to create PKGZIP packages to fillup remove repository.
    echo.
    echo        version
    echo            Show RSuite CLI version.
    echo.
    echo        help
    echo            Show this message and exit.
    echo.
    echo Call 'rsuite [command] help' to get information on acceptable [args].
    echo.
exit /B 0
