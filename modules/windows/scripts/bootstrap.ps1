<#
.SYNOPSIS
    Unified Declarative Bootstrap Script for Windows 11 Workstations
    Runs Winget DSC configuration and registry preferences.
#>
[CmdletBinding()]
param(
    [string]$ConfigPath = "$PSScriptRoot\..\winget\packages.work.yaml",
    [switch]$SkipRegistry
)

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "   Windows Declarative System Provisioner  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. Check WinGet
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "WinGet CLI was not detected. Please ensure App Installer is installed from the Microsoft Store."
    exit 1
}

# 2. Run WinGet DSC Declarative Configuration
Write-Host "`n[1/2] Applying declarative package configuration via WinGet DSC..." -ForegroundColor Yellow
winget configure -f $ConfigPath --accept-configuration-agreements

# 3. Apply Registry Tweaks
if (-not $SkipRegistry) {
    Write-Host "`n[2/2] Applying declarative registry adjustments..." -ForegroundColor Yellow
    $regScript = Join-Path $PSScriptRoot "..\registry\explorer-tweaks.ps1"
    if (Test-Path $regScript) {
        & $regScript
    }
}

Write-Host "`nWindows configuration completed successfully!" -ForegroundColor Green
