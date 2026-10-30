# ==============================================================================
# WINDOWS DSC MODULE: modules/windows/dsc/FileShares.ps1
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Declarative SMB Network Share Mounts for USD 308 Windows Workstations using
#   PowerShell Desired State Configuration (PSDesiredStateConfiguration).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   On NixOS ('modules/nixos/services/308-storage.nix'), systemd mounts our
#   USD 308 network shares automatically. On Windows, PowerShell DSC uses a
#   3-step loop (Get -> Test -> Set) to guarantee the exact same result:
#     - 'TestScript': Checks if the drive letter (e.g. 'S:' or 'W:') already exists.
#     - 'SetScript' : Only runs if 'TestScript' returns False, mapping the network
#                     share persistently across reboots.
# ==============================================================================

Configuration USD308Storage {
    # Import the built-in Windows Desired State Configuration resource library
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    Node "localhost" {
        # ----------------------------------------------------------------------
        # 1. USD 308 Technology Support Center (TSC) CloudStorage -> Drive S:
        # ----------------------------------------------------------------------
        Script MountCloudStorage {
            GetScript = {
                # Returns current state of the S: drive for DSC reporting
                return @{ Result = (Test-Path -Path "S:") }
            }
            TestScript = {
                # If S: is already mounted, return True (nothing to do)
                return (Test-Path -Path "S:")
            }
            SetScript = {
                # Mounts \\cloud-storage.usd308.com\Resources\TSC as S: persistently
                New-PSDrive -Name "S" -PSProvider FileSystem -Root "\\cloud-storage.usd308.com\Resources\TSC" -Persist -Scope Global
            }
        }

        # ----------------------------------------------------------------------
        # 2. Personal Technician Backup Share (JoshBackups) -> Drive W:
        # ----------------------------------------------------------------------
        Script MountWorkStorage {
            GetScript = {
                # Returns current state of the W: drive for DSC reporting
                return @{ Result = (Test-Path -Path "W:") }
            }
            TestScript = {
                # If W: is already mounted, return True (nothing to do)
                return (Test-Path -Path "W:")
            }
            SetScript = {
                # Mounts \\172.16.3.0\Backups\JoshBackups as W: persistently
                New-PSDrive -Name "W" -PSProvider FileSystem -Root "\\172.16.3.0\Backups\JoshBackups" -Persist -Scope Global
            }
        }
    }
}
