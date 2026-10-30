<#
.SYNOPSIS
  USD 308 Project 14: Automated uninstaller and deep remnant scrubber for
  Autodesk Fusion, FeatureCAM, and Genuine Service on Windows 11.
#>
[CmdletBinding()]
param([switch]$DryRun)

$ErrorActionPreference = 'SilentlyContinue'
Write-Host "==> [1/4] Terminating lingering Autodesk background processes..." -ForegroundColor Cyan
$procs = @(
  "AdskIdentityManager", "AdskLicensingService", "AdAppMgrSvc",
  "AutodeskDesktopApp", "Fusion360", "senddmp", "GenuineService"
)
foreach ($p in $procs) {
  if (-not $DryRun) { Stop-Process -Name $p -Force }
}

Write-Host "==> [2/4] Stopping and removing Autodesk Windows Services..." -ForegroundColor Cyan
$svcs = @("AdskLicensingService", "AdAppMgrSvc", "Autodesk Access Service Host")
foreach ($s in $svcs) {
  if (-not $DryRun) {
    Stop-Service -Name $s -Force
    sc.exe delete "$s" | Out-Null
  }
}

Write-Host "==> [3/4] Purging lingering Autodesk filesystem directories..." -ForegroundColor Cyan
$paths = @(
  "$env:ProgramFiles\Autodesk",
  "${env:ProgramFiles(x86)}\Autodesk",
  "$env:ProgramFiles\Common Files\Autodesk Shared",
  "${env:ProgramFiles(x86)}\Common Files\Autodesk Shared",
  "$env:ProgramData\Autodesk",
  "$env:ProgramData\FLEXnet",
  "$env:LOCALAPPDATA\Autodesk",
  "$env:APPDATA\Autodesk"
)
foreach ($path in $paths) {
  if (Test-Path $path) {
    Write-Host "    Removing $path"
    if (-not $DryRun) { Remove-Item -Path $path -Recurse -Force }
  }
}

Write-Host "==> [4/4] Scrubbing Autodesk Registry keys (HKLM & HKCU)..." -ForegroundColor Cyan
$regKeys = @(
  "HKLM:\SOFTWARE\Autodesk",
  "HKLM:\SOFTWARE\WOW6432Node\Autodesk",
  "HKCU:\Software\Autodesk"
)
foreach ($rk in $regKeys) {
  if (Test-Path $rk) {
    Write-Host "    Removing $rk"
    if (-not $DryRun) { Remove-Item -Path $rk -Recurse -Force }
  }
}
Write-Host "==> Autodesk remnant scrub complete." -ForegroundColor Green
