<#
.SYNOPSIS
    Declarative SMB Network Share Mounts for USD 308 Windows Workstations
#>
Configuration USD308Storage {
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        Script MountCloudStorage {
            GetScript = {
                return @{ Result = (Test-Path -Path "S:") }
            }
            TestScript = {
                return (Test-Path -Path "S:")
            }
            SetScript = {
                New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\cloud-storage.usd308.com\Resources\TSC" -Persist -Scope Global
            }
        }

        Script MountWorkStorage {
            GetScript = {
                return @{ Result = (Test-Path -Path "W:") }
            }
            TestScript = {
                return (Test-Path -Path "W:")
            }
            SetScript = {
                New-PSDrive -Name "W" -PSProvider FileSystem -Root "\\172.16.3.0\Backups\JoshBackups" -Persist -Scope Global
            }
        }
    }
}
