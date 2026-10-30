<#
.SYNOPSIS
  USD 308 Project 10: Optimized UltraVNC silent installer and service registration for PDQ Deploy.
#>
param(
  [string]$InstallerPath = "\\pdq.usd308.com\Software\UltraVNC\UltraVNC_x64_Setup.exe",
  [string]$ConfigIni     = "\\pdq.usd308.com\Software\UltraVNC\ultravnc.ini"
)

$ErrorActionPreference = 'Stop'
Stop-Service -Name "uvnc_service" -Force -ErrorAction SilentlyContinue

Start-Process -FilePath $InstallerPath `
  -ArgumentList "/verysilent /norestart /loadinf=`"\\pdq.usd308.com\Software\UltraVNC\uvnc_install.inf`"" `
  -Wait -NoNewWindow

if (Test-Path $ConfigIni) {
  Copy-Item -Path $ConfigIni -Destination "$env:ProgramFiles\uvnc bvba\UltraVNC\ultravnc.ini" -Force
}

Set-Service -Name "uvnc_service" -StartupType Automatic
Start-Service -Name "uvnc_service"
