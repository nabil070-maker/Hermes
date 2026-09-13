# ================================================================
# Hermes Portable - Reset
# Windows PowerShell 5.1
# ================================================================

$ErrorActionPreference = "Stop"

# ================================================================
# ROOT
# ================================================================

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$Hermes  = Join-Path $Root "hermes-agent"
$Runtime = Join-Path $Root "runtime"
$Cache   = Join-Path $Root "cache"

$UvExe = Join-Path $Runtime "uv\uv.exe"

$HermesVenv = Join-Path $Hermes ".venv"

# ================================================================
# HEADER
# ================================================================

Clear-Host

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Red
Write-Host ""
Write-Host "                       HERMES PORTABLE" -ForegroundColor White
Write-Host ""
Write-Host "                           RESET" -ForegroundColor Red
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Red
Write-Host ""

# ================================================================
# CONFIRM
# ================================================================

Write-Host "  This reset will remove:" -ForegroundColor Yellow
Write-Host ""
Write-Host "    $HermesVenv" -ForegroundColor DarkGray
Write-Host ""

$Confirm = Read-Host "  Type RESET to continue"

if ($Confirm -ne "RESET") {
    Write-Host ""
    Write-Host "  Reset cancelled." -ForegroundColor Yellow
    exit 0
}

# ================================================================
# ENVIRONMENT
# ================================================================

$env:VIRTUAL_ENV = ""
$env:PYTHONUTF8 = "1"
$env:PYTHONNOUSERSITE = "1"

$PythonExe = Join-Path $Runtime "python\python.exe"

$env:UV_PYTHON = $PythonExe
$env:UV_CACHE_DIR = Join-Path $Cache "uv"

$env:PATH = `
    "$(Join-Path $Runtime 'python');" +
    "$(Join-Path $Runtime 'python\Scripts');" +
    "$(Join-Path $Runtime 'uv');" +
    "$(Join-Path $Runtime 'git\cmd');" +
    "$(Join-Path $Runtime 'node');" +
    "$(Join-Path $Runtime 'ripgrep');" +
    "$env:PATH"

# ================================================================
# REMOVE VENV
# ================================================================

if (Test-Path $HermesVenv) {

    Write-Host "  Removing Hermes .venv..." -ForegroundColor Cyan

    Remove-Item `
        -LiteralPath $HermesVenv `
        -Recurse `
        -Force

    Write-Host "  [OK] .venv removed" -ForegroundColor Green
}
else {
    Write-Host "  [OK] No existing .venv found" -ForegroundColor Green
}

# ================================================================
# RECREATE WITH UV
# ================================================================

if (-not (Test-Path $UvExe)) {
    throw "Portable uv was not found: $UvExe"
}

Set-Location $Hermes

Write-Host ""
Write-Host "  Rebuilding Hermes environment..." -ForegroundColor Cyan
Write-Host ""
Write-Host "  uv sync" -ForegroundColor White
Write-Host ""

& $UvExe sync

if ($LASTEXITCODE -ne 0) {
    throw "uv sync failed."
}

# ================================================================
# VERIFY
# ================================================================

$HermesExe = Join-Path $Hermes ".venv\Scripts\hermes.exe"

if (-not (Test-Path $HermesExe)) {
    throw "Hermes executable was not recreated:`n$HermesExe"
}

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "                       RESET COMPLETE" -ForegroundColor White
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "  Hermes:" -ForegroundColor Gray
Write-Host "  $HermesExe" -ForegroundColor Cyan
Write-Host ""

Set-Location $Root

exit 0