# ==============================================================================
# WINDOWS AUTOMATION SCRIPT: modules/windows/scripts/Remove-AutodeskRemnants.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 14):
#   Automated uninstaller and deep remnant scrubber for Autodesk Fusion,
#   FeatureCAM, and Autodesk Genuine Service on Windows 11 lab workstations.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When an Autodesk installation fails or gets corrupted on a classroom/lab PC,
#   simply running Windows "Add or Remove Programs" often leaves behind locked
#   background licensing services ('AdskLicensingService'), FLEXnet DRM files in
#   'C:\ProgramData', and orphaned Registry keys. Those leftover files cause any
#   subsequent reinstall via PDQ Deploy to fail with cryptic exit codes.
#   This script performs a clean 4-stage surgical wipe (or previews it safely
#   when passed '-DryRun') so the machine is ready for a fresh install.
# ==============================================================================

[CmdletBinding()]
param(
  # Pass -DryRun to preview which folders and registry keys would be removed
  # without actually deleting anything.
  [switch]$DryRun
)

# Continue past non-existent processes/services instead of halting early
$ErrorActionPreference = 'SilentlyContinue'

# ------------------------------------------------------------------------------
# STAGE 1: Terminate Lingering Background Processes
# ------------------------------------------------------------------------------
# Why: Windows prevents deleting folders in C:\Program Files if any executable
# inside them is still running in memory.
Write-Host "==> [1/4] Terminating lingering Autodesk background processes..." -ForegroundColor Cyan
$procs = @(
  "AdskIdentityManager", "AdskLicensingService", "AdAppMgrSvc",
  "AutodeskDesktopApp", "Fusion360", "senddmp", "GenuineService"
)
foreach ($p in $procs) {
  if (-not $DryRun) { Stop-Process -Name $p -Force }
}

# ------------------------------------------------------------------------------
# STAGE 2: Stop and Unregister Windows Services
# ------------------------------------------------------------------------------
# Why: 'sc.exe delete' removes the service registration from the Windows Service
# Control Manager so the new Autodesk ODIS installer can register fresh ones.
Write-Host "==> [2/4] Stopping and removing Autodesk Windows Services..." -ForegroundColor Cyan
$svcs = @("AdskLicensingService", "AdAppMgrSvc", "Autodesk Access Service Host")
foreach ($s in $svcs) {
  if (-not $DryRun) {
    Stop-Service -Name $s -Force
    sc.exe delete "$s" | Out-Null
  }
}

# ------------------------------------------------------------------------------
# STAGE 3: Purge Leftover Filesystem Directories
# ------------------------------------------------------------------------------
# Why: Clears cached installers, FLEXnet licensing tokens, and per-user AppData
# caches that block clean upgrades between school years.
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

# ------------------------------------------------------------------------------
# STAGE 4: Scrub Registry Hives (64-bit HKLM, 32-bit WOW6432Node, and HKCU)
# ------------------------------------------------------------------------------
# Why: Autodesk ODIS checks HKLM:\SOFTWARE\Autodesk to decide whether a product
# is already installed; stale keys trick the installer into aborting early.
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
