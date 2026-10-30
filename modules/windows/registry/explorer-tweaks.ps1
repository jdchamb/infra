# ==============================================================================
# WINDOWS REGISTRY MODULE: modules/windows/registry/explorer-tweaks.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Applies declarative Windows Explorer and taskbar ergonomics via HKCU
#   (Current User) Registry keys on Windows 11 nodes.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   By default, fresh Windows 11 installs hide file extensions (making a
#   malicious 'report.pdf.exe' look like 'report.pdf') and hide system folders
#   like 'AppData'. Just as 'system.defaults.finder' in nix-darwin configures
#   macOS Finder automatically, this script configures Windows Explorer so we
#   never have to click through Folder Options on a new Windows machine.
# ==============================================================================

[CmdletBinding()]
param()

Write-Host "Configuring Windows Explorer preferences..." -ForegroundColor Cyan

# 1. Always show file extensions (.exe, .ps1, .ini, .wim) in File Explorer
#    Why: Prevents extension spoofing and is essential for scripting/admin work.
#    Registry Value: HideFileExt = 0 (0 = Do NOT hide extensions)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force

# 2. Show hidden files and folders (e.g., C:\ProgramData and ~\AppData)
#    Why: IT administration frequently requires inspecting AppData and ProgramData logs.
#    Registry Value: Hidden = 1 (1 = Show hidden files, 2 = Do not show)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force

# 3. Align the Windows 11 Taskbar & Start Button to the left edge of the screen
#    Why: Matches traditional desktop layouts and muscle memory across monitors.
#    Registry Value: TaskbarAl = 0 (0 = Left aligned, 1 = Center aligned)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Force

Write-Host "Explorer preferences declared successfully." -ForegroundColor Green
