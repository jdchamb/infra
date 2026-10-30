# ==============================================================================
# WINDOWS AUTOMATION SCRIPT: modules/windows/scripts/Deploy-UltraVNC.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 10):
#   Optimized UltraVNC silent installer and service registration script designed
#   for automated execution via PDQ Deploy across USD 308 Windows endpoints.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   UltraVNC lets USD 308 technicians remotely view and assist classroom/office
#   PCs (connecting from Linux via 'krdc.nix' or 'tigervnc.nix').
#   When upgrading UltraVNC silently across hundreds of PCs via PDQ Deploy:
#     1. We must stop 'uvnc_service' first so 'winvnc.exe' isn't locked in RAM.
#     2. We pass '/verysilent /norestart /loadinf=...' to the InnoSetup installer
#        so no popup windows appear on a teacher's screen and the PC doesn't
#        unexpectedly reboot mid-class.
#     3. We copy the pre-configured 'ultravnc.ini' (containing our encrypted VNC
#        authentication settings and MSLogon ACLs) into Program Files and restart
#        the background service.
# ==============================================================================

param(
  # UNC path to the UltraVNC 64-bit InnoSetup installer on the PDQ file server
  [string]$InstallerPath = "\\pdq.usd308.com\Software\UltraVNC\UltraVNC_x64_Setup.exe",

  # UNC path to the pre-configured ultravnc.ini settings file
  [string]$ConfigIni     = "\\pdq.usd308.com\Software\UltraVNC\ultravnc.ini"
)

# Halt immediately if the installer binary is unreachable or returns an error
$ErrorActionPreference = 'Stop'

# 1. Stop any existing UltraVNC service so its binaries can be overwritten cleanly
Stop-Service -Name "uvnc_service" -Force -ErrorAction SilentlyContinue

# 2. Execute the silent InnoSetup installation using our standard answer file (.inf)
Start-Process -FilePath $InstallerPath `
  -ArgumentList "/verysilent /norestart /loadinf=`"\\pdq.usd308.com\Software\UltraVNC\uvnc_install.inf`"" `
  -Wait -NoNewWindow

# 3. Deploy the standardized USD 308 UltraVNC configuration (ports, passwords, DSM)
if (Test-Path $ConfigIni) {
  Copy-Item -Path $ConfigIni -Destination "$env:ProgramFiles\uvnc bvba\UltraVNC\ultravnc.ini" -Force
}

# 4. Ensure the UltraVNC system service starts automatically on every Windows boot
Set-Service -Name "uvnc_service" -StartupType Automatic
Start-Service -Name "uvnc_service"
