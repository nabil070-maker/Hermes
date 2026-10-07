# ================================================================
# Hermes Portable - Setup
# Windows PowerShell 5.1
# ================================================================

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# ================================================================
# ROOT
# ================================================================

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

$Scripts     = Join-Path $Root "scripts"
$Runtime     = Join-Path $Root "runtime"
$Cache       = Join-Path $Root "cache"
$Data        = Join-Path $Root "data"
$Hermes      = Join-Path $Root "hermes-agent"

$PythonRoot  = Join-Path $Runtime "python"
$NodeRoot    = Join-Path $Runtime "node"
$GitRoot     = Join-Path $Runtime "git"
$UvRoot      = Join-Path $Runtime "uv"
$RgRoot      = Join-Path $Runtime "ripgrep"

$UvCache     = Join-Path $Cache "uv"

# ================================================================
# PINNED DOWNLOADS
# ================================================================

$GitUrl = "https://github.com/git-for-windows/git/releases/download/v2.55.0.windows.5/MinGit-2.55.0.5-64-bit.zip"

$NodeUrl = "https://nodejs.org/dist/v26.10.0/node-v26.10.0-win-x64.zip"

$PythonUrl = "https://github.com/astral-sh/python-build-standalone/releases/download/20260924/cpython-3.14.7+20260924-x86_64-pc-windows-msvc-install_only.tar.gz"

$UvUrl = "https://releases.astral.sh/github/uv/releases/download/0.12.13/uv-x86_64-pc-windows-msvc.zip"

$RgUrl = "https://github.com/BurntSushi/ripgrep/releases/download/15.2.0/ripgrep-15.2.0-x86_64-pc-windows-msvc.zip"

# Hermes source
$HermesRepo = "https://github.com/NousResearch/hermes-agent.git"

# ================================================================
# DOWNLOAD FILES
# ================================================================

$GitZip    = Join-Path $Cache "git.zip"
$NodeZip   = Join-Path $Cache "node.zip"
$PythonTar = Join-Path $Cache "python.tar.gz"
$UvZip     = Join-Path $Cache "uv.zip"
$RgZip     = Join-Path $Cache "ripgrep.zip"

# ================================================================
# FUNCTIONS
# ================================================================

function Write-Step {
    param([string]$Text)

    Write-Host ""
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "  ------------------------------------------------------------" -ForegroundColor DarkGray
}

function Write-OK {
    param([string]$Text)

    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)

    Write-Host "  [!] $Text" -ForegroundColor Yellow
}

function Write-Fail {
    param([string]$Text)

    Write-Host "  [X] $Text" -ForegroundColor Red
}

function Ensure-Directory {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Download-File {
    param(
        [string]$Url,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        Write-Host "  Using cached file: $(Split-Path $Destination -Leaf)" -ForegroundColor DarkGray
        return
    }

    Write-Host "  Downloading:" -ForegroundColor Gray
    Write-Host "  $Url" -ForegroundColor DarkGray

    Invoke-WebRequest `
        -Uri $Url `
        -OutFile $Destination `
        -UseBasicParsing

    if (-not (Test-Path -LiteralPath $Destination)) {
        throw "Download failed: $Destination"
    }

    Write-OK "Downloaded $(Split-Path $Destination -Leaf)"
}

function Extract-Zip {
    param(
        [string]$Archive,
        [string]$Destination
    )

    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }

    Ensure-Directory $Destination

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    [System.IO.Compression.ZipFile]::ExtractToDirectory(
        $Archive,
        $Destination
    )
}

function Get-SingleDirectory {
    param([string]$Path)

    $Dirs = @(Get-ChildItem -LiteralPath $Path -Directory)

    if ($Dirs.Count -eq 1) {
        return $Dirs[0].FullName
    }

    return $Path
}

# ================================================================
# START
# ================================================================

Clear-Host

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "                       HERMES PORTABLE" -ForegroundColor White
Write-Host ""
Write-Host "                       PORTABLE SETUP" -ForegroundColor Cyan
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""

# ================================================================
# SYSTEM CHECK
# ================================================================

Write-Step "Checking system"

if (-not [Environment]::Is64BitOperatingSystem) {
    throw "64-bit Windows is required."
}

if ($env:OS -ne "Windows_NT") {
    throw "Windows is required."
}

Write-OK "64-bit Windows detected"

# ================================================================
# DIRECTORIES
# ================================================================

Write-Step "Preparing portable directories"

Ensure-Directory $Runtime
Ensure-Directory $Cache
Ensure-Directory $Data
Ensure-Directory $UvCache

Write-OK "Portable directory structure ready"

# ================================================================
# PORTABLE ENVIRONMENT
# ================================================================

Write-Step "Configuring portable environment"

$env:VIRTUAL_ENV = ""
$env:PYTHONUTF8 = "1"
$env:PYTHONNOUSERSITE = "1"

$env:UV_PYTHON = Join-Path $PythonRoot "python.exe"
$env:UV_CACHE_DIR = $UvCache

$env:PATH = "$PythonRoot;$PythonRoot\Scripts;$NodeRoot;$NodeRoot\bin;$GitRoot\cmd;$GitRoot\usr\bin;$UvRoot;$RgRoot;$env:PATH"

Write-OK "Portable environment configured"

# ================================================================
# PYTHON
# ================================================================

Write-Step "Installing portable Python 3.14.7"

if (-not (Test-Path (Join-Path $PythonRoot "python.exe"))) {

    Download-File $PythonUrl $PythonTar

    Ensure-Directory $PythonRoot

    Write-Host "  Extracting Python..." -ForegroundColor Gray

    tar.exe -xzf $PythonTar -C $PythonRoot

    if ($LASTEXITCODE -ne 0) {
        throw "Python archive extraction failed."
    }

    # install_only archive normally extracts its Python tree.
    $PythonExe = Get-ChildItem `
        -LiteralPath $PythonRoot `
        -Filter "python.exe" `
        -File `
        -Recurse `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if (-not $PythonExe) {
        throw "python.exe was not found after extraction."
    }

    if ($PythonExe.Directory.FullName -ne $PythonRoot) {

        $PythonActual = $PythonExe.Directory.FullName

        Get-ChildItem -LiteralPath $PythonActual -Force |
            Move-Item -Destination $PythonRoot -Force

        Remove-Item -LiteralPath $PythonActual -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$PythonExePath = Join-Path $PythonRoot "python.exe"

if (-not (Test-Path $PythonExePath)) {
    throw "Portable Python installation failed."
}

$PythonVersion = & $PythonExePath --version 2>&1

Write-OK "Python ready: $PythonVersion"

# ================================================================
# GIT
# ================================================================

Write-Step "Installing portable Git"

if (-not (Test-Path (Join-Path $GitRoot "cmd\git.exe"))) {

    Download-File $GitUrl $GitZip

    Extract-Zip $GitZip $GitRoot

    # MinGit ZIP contains cmd/git.exe directly.
    if (-not (Test-Path (Join-Path $GitRoot "cmd\git.exe"))) {

        $GitNested = Get-ChildItem `
            -LiteralPath $GitRoot `
            -Directory |
            Select-Object -First 1

        if ($GitNested) {
            Get-ChildItem -LiteralPath $GitNested.FullName -Force |
                Move-Item -Destination $GitRoot -Force

            Remove-Item -LiteralPath $GitNested.FullName -Recurse -Force
        }
    }
}

$GitExe = Join-Path $GitRoot "cmd\git.exe"

if (-not (Test-Path $GitExe)) {
    throw "Portable Git installation failed."
}

$GitVersion = & $GitExe --version

Write-OK "Git ready: $GitVersion"

# ================================================================
# NODE
# ================================================================

Write-Step "Installing portable Node.js 26.8.2"

if (-not (Test-Path (Join-Path $NodeRoot "node.exe"))) {

    Download-File $NodeUrl $NodeZip

    $NodeExtract = Join-Path $Cache "node-extract"

    if (Test-Path $NodeExtract) {
        Remove-Item $NodeExtract -Recurse -Force
    }

    Extract-Zip $NodeZip $NodeExtract

    $NodeDir = Get-SingleDirectory $NodeExtract

    Ensure-Directory $NodeRoot

    Get-ChildItem -LiteralPath $NodeDir -Force |
        Move-Item -Destination $NodeRoot -Force

    Remove-Item $NodeExtract -Recurse -Force
}

$NodeExe = Join-Path $NodeRoot "node.exe"

if (-not (Test-Path $NodeExe)) {
    throw "Portable Node.js installation failed."
}

$NodeVersion = & $NodeExe --version

Write-OK "Node.js ready: $NodeVersion"

# ================================================================
# UV
# ================================================================

Write-Step "Installing portable uv 0.12.13"

if (-not (Test-Path (Join-Path $UvRoot "uv.exe"))) {

    Download-File $UvUrl $UvZip

    $UvExtract = Join-Path $Cache "uv-extract"

    if (Test-Path $UvExtract) {
        Remove-Item $UvExtract -Recurse -Force
    }

    Extract-Zip $UvZip $UvExtract

    Ensure-Directory $UvRoot

    $UvExeSource = Get-ChildItem `
        -LiteralPath $UvExtract `
        -Filter "uv.exe" `
        -File `
        -Recurse |
        Select-Object -First 1

    if (-not $UvExeSource) {
        throw "uv.exe was not found."
    }

    Copy-Item `
        -LiteralPath $UvExeSource.FullName `
        -Destination (Join-Path $UvRoot "uv.exe") `
        -Force

    Remove-Item $UvExtract -Recurse -Force
}

$UvExe = Join-Path $UvRoot "uv.exe"

if (-not (Test-Path $UvExe)) {
    throw "Portable uv installation failed."
}

$UvVersion = & $UvExe --version

Write-OK "uv ready: $UvVersion"

# ================================================================
# RIPGREP
# ================================================================

Write-Step "Installing portable ripgrep 15.2.0"

if (-not (Test-Path (Join-Path $RgRoot "rg.exe"))) {

    Download-File $RgUrl $RgZip

    $RgExtract = Join-Path $Cache "ripgrep-extract"

    if (Test-Path $RgExtract) {
        Remove-Item $RgExtract -Recurse -Force
    }

    Extract-Zip $RgZip $RgExtract

    Ensure-Directory $RgRoot

    $RgExeSource = Get-ChildItem `
        -LiteralPath $RgExtract `
        -Filter "rg.exe" `
        -File `
        -Recurse |
        Select-Object -First 1

    if (-not $RgExeSource) {
        throw "rg.exe was not found."
    }

    Copy-Item `
        -LiteralPath $RgExeSource.FullName `
        -Destination (Join-Path $RgRoot "rg.exe") `
        -Force

    Remove-Item $RgExtract -Recurse -Force
}

$RgExe = Join-Path $RgRoot "rg.exe"

if (-not (Test-Path $RgExe)) {
    throw "ripgrep installation failed."
}

$RgVersion = & $RgExe --version | Select-Object -First 1

Write-OK "ripgrep ready: $RgVersion"

# ================================================================
# HERMES SOURCE
# ================================================================

Write-Step "Preparing Hermes source"

if (-not (Test-Path (Join-Path $Hermes "pyproject.toml"))) {

    if (Test-Path $Hermes) {
        Remove-Item $Hermes -Recurse -Force
    }

    & $GitExe clone $HermesRepo $Hermes

    if ($LASTEXITCODE -ne 0) {
        throw "Hermes repository clone failed."
    }
}

if (-not (Test-Path (Join-Path $Hermes "pyproject.toml"))) {
    throw "Hermes pyproject.toml was not found."
}

Write-OK "Hermes source ready"

# ================================================================
# HERMES VENV
# ================================================================

Write-Step "Creating Hermes environment with uv"

# Never allow a host virtual environment to affect uv.
$env:VIRTUAL_ENV = ""

# Make absolutely sure uv uses our portable Python.
$env:UV_PYTHON = $PythonExePath
$env:UV_CACHE_DIR = $UvCache

Set-Location $Hermes

if ($Force -and (Test-Path (Join-Path $Hermes ".venv"))) {
    Write-Host "  Removing existing Hermes .venv..." -ForegroundColor Yellow

    Remove-Item `
        -LiteralPath (Join-Path $Hermes ".venv") `
        -Recurse `
        -Force
}

# ------------------------------------------------------------
# IMPORTANT:
#
# We intentionally use ONLY:
#
#     uv sync
#
# No pip.
# No python -m venv.
# No manual package installation.
# No ".[all]".
#
# uv creates .venv and installs the project dependencies from
# the Hermes project/lockfile.
# ------------------------------------------------------------

Write-Host ""
Write-Host "  Running:" -ForegroundColor Gray
Write-Host "  uv sync" -ForegroundColor White
Write-Host ""

& $UvExe sync

if ($LASTEXITCODE -ne 0) {
    throw "uv sync failed."
}

Write-OK "uv sync completed"

# ================================================================
# VERIFY HERMES
# ================================================================

Write-Step "Verifying Hermes installation"

$HermesExe = Join-Path $Hermes ".venv\Scripts\hermes.exe"

if (-not (Test-Path $HermesExe)) {
    throw "Hermes installation completed but hermes.exe was not found at:`n$HermesExe"
}

Write-OK "Hermes executable found"
Write-Host "  $HermesExe" -ForegroundColor DarkGray

# ================================================================
# VERIFY ALL PORTABLE COMPONENTS
# ================================================================

Write-Step "Running final component checks"

$Checks = @(
    @{ Name = "Python"; Path = $PythonExePath },
    @{ Name = "Git"; Path = $GitExe },
    @{ Name = "Node"; Path = $NodeExe },
    @{ Name = "uv"; Path = $UvExe },
    @{ Name = "ripgrep"; Path = $RgExe },
    @{ Name = "Hermes"; Path = $HermesExe }
)

foreach ($Check in $Checks) {

    if (-not (Test-Path $Check.Path)) {
        throw "$($Check.Name) verification failed."
    }

    Write-OK "$($Check.Name) verified"
}

# ================================================================
# CLEAN CACHE
# ================================================================

Write-Step "Cleaning setup cache"

Set-Location $Root

if (Test-Path $Cache) {

    Get-ChildItem -LiteralPath $Cache -Force |
        Remove-Item -Recurse -Force -ErrorAction Stop
}

Ensure-Directory $Cache

Write-OK "Cache cleaned"

# ================================================================
# COMPLETE
# ================================================================

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "                    HERMES SETUP COMPLETE" -ForegroundColor White
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""

Write-Host "  Hermes:" -ForegroundColor Gray
Write-Host "  $HermesExe" -ForegroundColor Cyan

Write-Host ""
Write-Host "  Portable runtimes:" -ForegroundColor Gray
Write-Host "  Python     $PythonRoot" -ForegroundColor DarkGray
Write-Host "  Node       $NodeRoot" -ForegroundColor DarkGray
Write-Host "  Git        $GitRoot" -ForegroundColor DarkGray
Write-Host "  uv         $UvRoot" -ForegroundColor DarkGray
Write-Host "  ripgrep    $RgRoot" -ForegroundColor DarkGray

Write-Host ""
Write-Host "  Setup finished successfully." -ForegroundColor Green
Write-Host ""

Set-Location $Root

exit 0
