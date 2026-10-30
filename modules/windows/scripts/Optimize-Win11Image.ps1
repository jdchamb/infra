<#
.SYNOPSIS
  USD 308 Project 5: Offline DISM Windows 11 deployment image optimizer.
  Strips consumer bloatware Appx packages and compacts the WIM image.
#>
param(
  [Parameter(Mandatory=$true)][string]$WimPath,
  [int]$Index = 1,
  [string]$MountDir = "C:\Mount\Win11"
)

New-Item -ItemType Directory -Force -Path $MountDir | Out-Null
Mount-WindowsImage -ImagePath $WimPath -Index $Index -Path $MountDir

$bloatApps = @(
  "Microsoft.BingNews", "Microsoft.BingWeather", "Microsoft.GamingApp",
  "Microsoft.GetHelp", "Microsoft.Getstarted", "Microsoft.MicrosoftOfficeHub",
  "Microsoft.MicrosoftSolitaireCollection", "Microsoft.People",
  "Microsoft.PowerAutomateDesktop", "Microsoft.Todos", "Microsoft.WindowsCommunicationsApps",
  "Microsoft.WindowsFeedbackHub", "Microsoft.Xbox.TCUI", "Microsoft.XboxGameOverlay",
  "Microsoft.XboxGamingOverlay", "Microsoft.XboxIdentityProvider",
  "Microsoft.XboxSpeechToTextOverlay", "Microsoft.YourPhone", "Microsoft.ZuneMusic",
  "Microsoft.ZuneVideo", "MicrosoftTeams"
)

$provisioned = Get-AppxProvisionedPackage -Path $MountDir
foreach ($app in $bloatApps) {
  $match = $provisioned | Where-Object { $_.DisplayName -eq $app }
  if ($match) {
    Write-Host "==> Removing provisioned Appx: $app"
    Remove-AppxProvisionedPackage -Path $MountDir -PackageName $match.PackageName | Out-Null
  }
}

Dismount-WindowsImage -Path $MountDir -Save
Export-WindowsImage -SourceImagePath $WimPath -SourceIndex $Index `
  -DestinationImagePath "$WimPath.optimized.wim" -CompressionType max
