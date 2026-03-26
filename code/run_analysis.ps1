#!/usr/bin/env pwsh
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Write-Section([string]$Message) {
    Write-Host ""
    Write-Host "=== $Message ==="
}

function Test-CommandExists {
    param([Parameter(Mandatory = $true)][string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-WinGet {
    if (-not (Test-CommandExists "winget")) {
        throw @"
WinGet is not installed or not on PATH.

Install 'App Installer' from the Microsoft Store, then re-run this script.
"@
    }
}

function Install-WinGetPackage {
    param([Parameter(Mandatory = $true)][string]$Id)

    Ensure-WinGet
    Write-Host "Installing $Id via WinGet..."
    & winget install --exact --id $Id --accept-package-agreements --accept-source-agreements --silent
}

function Invoke-Python {
    param([Parameter(Mandatory = $true)][string[]]$Args)

    if (Test-CommandExists "py") {
        & py -3 @Args
        return
    }

    if (Test-CommandExists "python") {
        & python @Args
        return
    }

    throw "Neither 'py' nor 'python' is available."
}

function Ensure-Python {
    if (Test-CommandExists "py") {
        try {
            & py -3 --version | Out-Host
            return
        } catch {}
    }

    if (Test-CommandExists "python") {
        try {
            & python --version | Out-Host
            return
        } catch {}
    }

    Install-WinGetPackage -Id "Python.Python.3.13"

    if (-not (Test-CommandExists "py") -and -not (Test-CommandExists "python")) {
        throw "Python installation completed, but Python is still not available on PATH."
    }
}

function Get-RScriptPath {

    # 1. Try PATH first
    $cmd = Get-Command "Rscript.exe" -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    # 2. Search default install directory
    $base = "C:\Program Files\R"
    if (Test-Path $base) {
        $rscript = Get-ChildItem -Path $base -Recurse -Filter "Rscript.exe" -ErrorAction SilentlyContinue |
                   Sort-Object FullName -Descending |
                   Select-Object -First 1

        if ($rscript) {
            return $rscript.FullName
        }
    }

    return $null
}

function Ensure-R {

    $rscript = Get-RScriptPath
    if ($rscript) {
        & $rscript --version | Out-Host
        return $rscript
    }

    Install-WinGetPackage -Id "RProject.R"

    # Try again after install
    $rscript = Get-RScriptPath
    if ($rscript) {
        & $rscript --version | Out-Host
        return $rscript
    }

    throw @"
R appears to be installed but could not be located.

Try restarting PowerShell, or verify installation in:
C:\Program Files\R
"@
}

# Script location and project root
$ScriptDir = Split-Path -Parent $PSCommandPath
$RootDir = Resolve-Path (Join-Path $ScriptDir "..")
Set-Location $RootDir.Path

Write-Host "Project root: $($RootDir.Path)"

New-Item -ItemType Directory -Force -Path (Join-Path $RootDir.Path "results") | Out-Null

Write-Section "Checking Python"
Ensure-Python
Invoke-Python -Args @('--version')

Write-Section "Checking R"
$rscript = Ensure-R

Write-Section "Installing Python dependencies if needed"
$ReqFile = Join-Path $RootDir.Path "code/python/requirements.txt"
if (Test-Path $ReqFile) {
    Invoke-Python -Args @('-m', 'pip', 'install', '-r', $ReqFile)
}

Write-Section "Ensuring Jupyter is installed"
Invoke-Python -Args @('-m', 'pip', 'install', '--upgrade', 'pip')
Invoke-Python -Args @('-m', 'pip', 'install', '--upgrade', 'jupyter', 'nbconvert')

Write-Section "Running Python notebook"
Invoke-Python -Args @(
    '-m', 'nbconvert',
    '--to', 'notebook',
    '--execute',
    '--inplace',
    'code/python/notebook.ipynb'
)

$rscript = Ensure-R

Write-Section "Running R SEM analysis"
& $rscript 'code/r/sem_analysis.R'

Write-Host ""
Write-Host "Pipeline finished successfully."