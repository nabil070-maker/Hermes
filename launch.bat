@echo off
setlocal EnableExtensions

title Hermes Portable

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "SCRIPTS=%ROOT%\scripts"
set "RUNTIME=%ROOT%\runtime"
set "PYTHON_HOME=%RUNTIME%\python"
set "NODE_HOME=%RUNTIME%\node"
set "GIT_HOME=%RUNTIME%\git"
set "UV_HOME=%RUNTIME%\uv"
set "RG_HOME=%RUNTIME%\ripgrep"
set "HERMES_HOME=%ROOT%\hermes-agent"
set "DATA_HOME=%ROOT%\data"
set "CACHE_HOME=%ROOT%\cache"

rem ------------------------------------------------------------
rem Portable environment
rem ------------------------------------------------------------

set "PYTHONUTF8=1"
set "PYTHONNOUSERSITE=1"

set "UV_PYTHON=%PYTHON_HOME%\python.exe"
set "UV_CACHE_DIR=%CACHE_HOME%\uv"

set "HERMES_HOME=%HERMES_HOME%"
set "HERMES_DATA_DIR=%DATA_HOME%"

rem Prevent host virtual environment from interfering.
set "VIRTUAL_ENV="

rem Portable PATH
set "PATH=%PYTHON_HOME%;%PYTHON_HOME%\Scripts;%NODE_HOME%;%NODE_HOME%\bin;%GIT_HOME%\cmd;%GIT_HOME%\usr\bin;%UV_HOME%;%RG_HOME%;%PATH%"

rem ------------------------------------------------------------
rem Check setup
rem ------------------------------------------------------------

if not exist "%HERMES_HOME%\.venv\Scripts\hermes.exe" (
    cls
    echo.
    echo  ============================================================
    echo.
    echo                       HERMES PORTABLE
    echo.
    echo                       FIRST-TIME SETUP
    echo.
    echo  ============================================================
    echo.
    echo  Hermes is not installed yet.
    echo.
    echo  Starting portable setup...
    echo.

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%\setup.ps1"

    if errorlevel 1 (
        echo.
        echo  ============================================================
        echo.
        echo                         SETUP FAILED
        echo.
        echo  ============================================================
        echo.
        pause
        exit /b 1
    )

    echo.
    echo  Setup completed successfully.
    echo.
)

rem ------------------------------------------------------------
rem Start shell
rem ------------------------------------------------------------

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPTS%\shell.ps1"

set "EXITCODE=%ERRORLEVEL%"

endlocal
exit /b %EXITCODE%
