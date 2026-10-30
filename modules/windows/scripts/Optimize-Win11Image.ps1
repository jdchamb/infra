# ==============================================================================
# WINDOWS AUTOMATION SCRIPT: modules/windows/scripts/Optimize-Win11Image.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 5):
#   Offline DISM (Deployment Image Servicing and Management) Windows 11 image
#   optimizer. Strips consumer bloatware Appx packages and compacts the resulting
#   'install.wim' image prior to PXE/USB deployment.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   A stock Windows 11 ISO ('install.wim') comes pre-loaded with "provisioned"
#   consumer apps (Xbox overlays, Solitaire, Bing News, Consumer Teams) that get
#   copied into every new student or teacher profile on first login—slowing down
#   first-time sign-ins and wasting disk space.
#   By mounting 'install.wim' offline with 'Mount-WindowsImage' and stripping
#   those provisioned packages BEFORE the OS is ever installed on a PC, every
#   newly imaged USD 308 computer boots fast and clean out of the box.
# ==============================================================================

param(
  # Path to the source Windows 11 install.wim file extracted from the ISO
  [Parameter(Mandatory=$true)][string]$WimPath,

  # Image index inside install.wim (e.g., Index 1 or Index 3 for Windows 11 Edu/Ent)
  [int]$Index = 1,

  # Temporary local directory where the WIM filesystem will be mounted offline
  [string]$MountDir = "C:\Mount\Win11"
)

# 1. Create the temporary mount folder and mount the offline Windows 11 image
New-Item -ItemType Directory -Force -Path $MountDir | Out-Null
Mount-WindowsImage -ImagePath $WimPath -Index $Index -Path $MountDir

# 2. List of consumer Appx packages to remove from the default user template
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

# 3. Query all provisioned packages inside the mounted image and remove matches
$provisioned = Get-AppxProvisionedPackage -Path $MountDir
foreach ($app in $bloatApps) {
  $match = $provisioned | Where-Object { $_.DisplayName -eq $app }
  if ($match) {
    Write-Host "==> Removing provisioned Appx: $app"
    Remove-AppxProvisionedPackage -Path $MountDir -PackageName $match.PackageName | Out-Null
  }
}

# 4. Commit changes back to the WIM and export a maximally compressed copy
#    Why Export-WindowsImage: Removing files from a WIM leaves dead space inside
#    the archive until you export the index with '-CompressionType max'.
Dismount-WindowsImage -Path $MountDir -Save
Export-WindowsImage -SourceImagePath $WimPath -SourceIndex $Index `
  -DestinationImagePath "$WimPath.optimized.wim" -CompressionType max
