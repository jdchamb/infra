# ==============================================================================
# WINDOWS AUTOMATION SCRIPT: modules/windows/scripts/Deploy-AutodeskFusionFeatureCAM.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 9):
#   Silent admin deployment wrapper for Autodesk Fusion and the isolated
#   FeatureCAM ODIS (Autodesk On-Demand Install Service) module workflow.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   By default, Autodesk Fusion installs into each individual user's '%LOCALAPPDATA%',
#   which breaks in shared school computer labs where dozens of different students
#   log into the same PC. Instead, we use 'FusionAdminInstall.exe --process install --quiet'
#   to install Fusion machine-wide into 'C:\Program Files'.
#   Furthermore, only specific CNC/machining labs need 'FeatureCAM' (which is very
#   large). Isolating FeatureCAM behind the '-IncludeFeatureCAM' switch lets PDQ
#   deploy base Fusion everywhere and only add FeatureCAM to machining lab PCs.
# ==============================================================================

param(
  # Root UNC path to the Autodesk deployment share on the USD 308 PDQ server
  [string]$ShareRoot = "\\pdq.usd308.com\Software\Autodesk",

  # Optional switch: pass -IncludeFeatureCAM for CNC/machining lab classrooms
  [switch]$IncludeFeatureCAM
)

$ErrorActionPreference = 'Stop'

# 1. Deploy machine-wide Autodesk Fusion Admin Package silently
Write-Host "==> Installing Autodesk Fusion Admin Package..."
Start-Process -FilePath "$ShareRoot\Fusion\FusionAdminInstall.exe" `
  -ArgumentList "--process install --quiet" -Wait -NoNewWindow

# 2. Optionally deploy isolated FeatureCAM module using Autodesk ODIS Collection.xml
if ($IncludeFeatureCAM) {
  Write-Host "==> Installing Isolated FeatureCAM Module via Autodesk ODIS..."
  Start-Process -FilePath "$ShareRoot\FeatureCAM\image\Installer.exe" `
    -ArgumentList "-i deploy --offline_mode -q -o `"$ShareRoot\FeatureCAM\image\Collection.xml`"" `
    -Wait -NoNewWindow
}
