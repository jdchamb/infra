# ==============================================================================
# WINDOWS BOOTSTRAP RUNNER: modules/windows/scripts/bootstrap.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   The Windows equivalent of our 'rebuild' command. Calling this script on a
#   fresh Windows 11 machine verifies WinGet is available, applies the
#   declarative YAML package list ('winget configure'), and applies our
#   File Explorer registry settings.
#
# HOW TO USE (ON WINDOWS 11):
#   1. Open PowerShell as Administrator.
#   2. Run:
#      Set-ExecutionPolicy RemoteSigned -Scope Process -Force
#      .\modules\windows\scripts\bootstrap.ps1
# ==============================================================================

[CmdletBinding()]
param(
    # Path to the WinGet DSC YAML manifest declaring all desired applications
    [string]$ConfigPath = "$PSScriptRoot\..\winget\packages.work.yaml",

    # Optional switch (--SkipRegistry) if you only want to install packages
    [switch]$SkipRegistry
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Windows Declarative System Provisioner  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# ------------------------------------------------------------------------------
# 1. VERIFY WINGET PACKAGE MANAGER
# ------------------------------------------------------------------------------
# Why: 'winget' is Microsoft's official command-line package manager built into
# modern Windows 11 via the 'App Installer' package.
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "WinGet CLI was not detected. Please ensure App Installer is installed from the Microsoft Store."
    exit 1
}

# ------------------------------------------------------------------------------
# 2. APPLY DECLARATIVE PACKAGE MANIFEST (WinGet DSC)
# ------------------------------------------------------------------------------
# Why: 'winget configure' reads our YAML file and automatically installs any
# missing applications while skipping ones that are already present.
Write-Host "`n[1/2] Applying declarative package configuration via WinGet DSC..." -ForegroundColor Yellow
winget configure -f $ConfigPath --accept-configuration-agreements

# ------------------------------------------------------------------------------
# 3. APPLY WINDOWS REGISTRY PREFERENCES
# ------------------------------------------------------------------------------
if (-not $SkipRegistry) {
    Write-Host "`n[2/2] Applying declarative registry adjustments..." -ForegroundColor Yellow
    $regScript = Join-Path $PSScriptRoot "..\registry\explorer-tweaks.ps1"
    if (Test-Path $regScript) {
        & $regScript
    }
}

Write-Host "`nWindows configuration completed successfully!" -ForegroundColor Green
