<#
.SYNOPSIS
    Declarative Windows Explorer & Environment Tweaks
#>
[CmdletBinding()]
param()

Write-Host "Configuring Windows Explorer preferences..." -ForegroundColor Cyan

# Show file extensions in Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Force

# Show hidden files in Explorer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Force

# Align taskbar to left (Windows 11)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Force

Write-Host "Explorer preferences declared successfully." -ForegroundColor Green
