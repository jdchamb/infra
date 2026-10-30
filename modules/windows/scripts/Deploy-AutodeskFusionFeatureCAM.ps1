<#
.SYNOPSIS
  USD 308 Project 9: Silent admin deployment wrapper for Autodesk Fusion
  and isolated FeatureCAM ODIS module workflow.
#>
param(
  [string]$ShareRoot = "\\pdq.usd308.com\Software\Autodesk",
  [switch]$IncludeFeatureCAM
)

$ErrorActionPreference = 'Stop'
Write-Host "==> Installing Autodesk Fusion Admin Package..."
Start-Process -FilePath "$ShareRoot\Fusion\FusionAdminInstall.exe" `
  -ArgumentList "--process install --quiet" -Wait -NoNewWindow

if ($IncludeFeatureCAM) {
  Write-Host "==> Installing Isolated FeatureCAM Module via Autodesk ODIS..."
  Start-Process -FilePath "$ShareRoot\FeatureCAM\image\Installer.exe" `
    -ArgumentList "-i deploy --offline_mode -q -o `"$ShareRoot\FeatureCAM\image\Collection.xml`"" `
    -Wait -NoNewWindow
}
