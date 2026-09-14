# ================================================================
# Hermes Portable Shell
# Windows PowerShell 5.1
# ================================================================

$ErrorActionPreference = "Continue"

# ================================================================
# ROOT
# ================================================================

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$Runtime = Join-Path $Root "runtime"
$Hermes  = Join-Path $Root "hermes-agent"
$Data    = Join-Path $Root "data"

$PythonRoot = Join-Path $Runtime "python"
$NodeRoot   = Join-Path $Runtime "node"
$GitRoot    = Join-Path $Runtime "git"
$UvRoot     = Join-Path $Runtime "uv"
$RgRoot     = Join-Path $Runtime "ripgrep"

$HermesExe = Join-Path $Hermes ".venv\Scripts\hermes.exe"

# ================================================================
# PORTABLE ENVIRONMENT
# ================================================================

$env:VIRTUAL_ENV = ""
$env:PYTHONUTF8 = "1"
$env:PYTHONNOUSERSITE = "1"

$env:UV_PYTHON = Join-Path $PythonRoot "python.exe"
$env:UV_CACHE_DIR = Join-Path $Root "cache"

$env:HERMES_HOME = $Hermes
$env:HERMES_DATA_DIR = $Data

$env:PATH = "$PythonRoot;$PythonRoot\Scripts;$NodeRoot;$NodeRoot\bin;$GitRoot\cmd;$GitRoot\usr\bin;$UvRoot;$RgRoot;$env:PATH"

Set-Location $Root
function hermes {
    & $HermesExe @args
}

# ================================================================
# COLORS
# ================================================================

function Write-C {
    param(
        [string]$Text,
        [ConsoleColor]$Color = [ConsoleColor]::White
    )

    Write-Host $Text -ForegroundColor $Color
}

function Header {
    Clear-Host

    Write-Host ""
    Write-C "  ============================================================" Cyan
    Write-Host ""
    Write-C "                         HERMES" White
    Write-C "                       PORTABLE SHELL" Cyan
    Write-Host ""
    Write-C "  ============================================================" Cyan
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    Write-C "  Press any key to return..." DarkGray
    [void][System.Console]::ReadKey($true)
}

function Run-Hermes {
    param(
        [string[]]$Arguments
    )

    if (-not (Test-Path $HermesExe)) {
        Write-C "  Hermes executable was not found." Red
        Write-Host ""
        Write-C "  Expected:" Yellow
        Write-C "  $HermesExe" DarkGray
        Pause-Menu
        return
    }

    Set-Location $Hermes

    & $HermesExe @Arguments

    Set-Location $Root
}

# ================================================================
# ADVANCED MENU
# ================================================================

function Advanced-Menu {

    while ($true) {

        Header

        Write-C "  ADVANCED" Yellow
        Write-Host ""

        Write-C "  [1] Hermes Doctor" White
        Write-C "  [2] Hermes Setup" White
        Write-C "  [3] Hermes Update" White
        Write-C "  [4] Reset Hermes" White
        Write-C "  [5] Open Hermes Folder" White
        Write-C "  [6] Open Data Folder" White
        Write-C "  [7] Open PowerShell Here" White
        Write-C "  [0] Back" DarkGray

        Write-Host ""
        $Choice = Read-Host "  Select"

        switch ($Choice) {

            "1" {
                Header
                Write-C "  HERMES DOCTOR" Yellow
                Write-Host ""
                Run-Hermes @("doctor")
                Pause-Menu
            }

            "2" {
                Header
                Write-C "  HERMES SETUP" Yellow
                Write-Host ""
                Run-Hermes @("setup")
                Pause-Menu
            }

            "3" {
                Header
                Write-C "  HERMES UPDATE" Yellow
                Write-Host ""
                Run-Hermes @("update")
                Pause-Menu
            }

            "4" {
                Header
                Write-C "  RESET HERMES" Red
                Write-Host ""
                Write-C "  This will reset the Hermes environment/data handled by reset.ps1." Yellow
                Write-Host ""

                $Confirm = Read-Host "  Type RESET to continue"

                if ($Confirm -eq "RESET") {

                    powershell.exe `
                        -NoProfile `
                        -ExecutionPolicy Bypass `
                        -File (Join-Path $Root "scripts\reset.ps1")

                }
                else {
                    Write-C "  Reset cancelled." DarkGray
                }

                Pause-Menu
            }

            "5" {
                Start-Process explorer.exe $Hermes
            }

            "6" {
                Start-Process explorer.exe $Data
            }

         "7" {
    $PortableBin = @(
        $PythonRoot
        (Join-Path $PythonRoot "Scripts")
        $NodeRoot
        (Join-Path $NodeRoot "bin")
        (Join-Path $GitRoot "cmd")
        (Join-Path $GitRoot "usr\bin")
        $UvRoot
        $RgRoot
        (Join-Path $Hermes ".venv\Scripts")
    )

    $PortablePath = ($PortableBin -join ";")

    $ChildCommand = @"
`$env:VIRTUAL_ENV = ''
`$env:PYTHONUTF8 = '1'
`$env:PYTHONNOUSERSITE = '1'
`$env:UV_PYTHON = '$($env:UV_PYTHON)'
`$env:UV_CACHE_DIR = '$($env:UV_CACHE_DIR)'
`$env:HERMES_HOME = '$Hermes'
`$env:HERMES_DATA_DIR = '$Data'
`$env:HERMES_EXE = '$HermesExe'
`$env:PATH = '$PortablePath;' + `$env:PATH

function hermes {
    & `$env:HERMES_EXE @args
}

Set-Location -LiteralPath '$Hermes'

Write-Host ''
Write-Host '  Hermes Portable PowerShell' -ForegroundColor Cyan
Write-Host '  Portable environment loaded.' -ForegroundColor Green
Write-Host ''
Write-Host '  Hermes: ' -NoNewline -ForegroundColor Gray
Write-Host `$env:HERMES_EXE -ForegroundColor DarkGray
Write-Host ''
"@

    Start-Process powershell.exe `
        -WorkingDirectory $Root `
        -ArgumentList @(
            "-NoExit"
            "-NoProfile"
            "-ExecutionPolicy"
            "Bypass"
            "-Command"
            $ChildCommand
        )
}            "0" {
                return
            }

            default {
                Write-C "  Invalid selection." Red
                Start-Sleep -Milliseconds 700
            }
        }
    }
}

# ================================================================
# MAIN MENU
# ================================================================

while ($true) {

    Header

    Write-C "  MAIN MENU" Yellow
    Write-Host ""

    Write-C "  [1] Start Hermes" White
    Write-C "  [2] Hermes TUI" White
    Write-C "  [3] Advanced" White
    Write-C "  [4] Home Folder" White
    Write-C "  [5] Clear Screen" White
    Write-C "  [0] Exit" DarkGray

    Write-Host ""
    Write-C "  ------------------------------------------------------------" DarkGray
    Write-C "  Hermes executable:" DarkGray
    Write-C "  $HermesExe" DarkGray
    Write-C "  ------------------------------------------------------------" DarkGray
    Write-Host ""

    $Choice = Read-Host "  Select"

    switch ($Choice) {

        "1" {
            Header
            Write-C "  STARTING HERMES" Cyan
            Write-Host ""

            Run-Hermes @()

            Pause-Menu
        }

        "2" {
            Header
            Write-C "  STARTING HERMES TUI" Cyan
            Write-Host ""

            Run-Hermes @("--tui")

            Pause-Menu
        }

        "3" {
            Advanced-Menu
        }

        "4" {
            Start-Process explorer.exe $Root
        }

        "5" {
            Clear-Host
        }

        "0" {
            Clear-Host
            Write-Host ""
            Write-C "  Hermes Portable closed." Cyan
            Write-Host ""
            exit 0
        }

        default {
            Write-C "  Invalid selection." Red
            Start-Sleep -Milliseconds 700
        }
    }
}
