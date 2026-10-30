# ==============================================================================
# WINDOWS HOST PROFILE: hosts/windows/wrk-win01/configuration.psd1
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   This PowerShell Data (.psd1) file defines the identity and module manifest
#   for 'wrk-win01', our Windows 11 target profile.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   While Windows does not use the Nix package store natively, we apply the
#   exact same "declarative infrastructure" philosophy on Windows 11 using:
#     1. WinGet DSC ('packages.work.yaml') to install applications automatically.
#     2. PowerShell Desired State Configuration ('FileShares.ps1') to mount
#        network drives idempotently.
#     3. Registry scripts ('explorer-tweaks.ps1') to set developer UI defaults.
#   This file acts like a Nix host 'default.nix' by tying those layers together.
# ==============================================================================

@{
    # Hostname identifier for the Windows 11 target node
    NodeName          = 'wrk-win01'

    # Machine role classification (Workstation vs Server)
    Role              = 'Workstation'

    # Declarative WinGet package manifest (7-Zip, Git, Windows Terminal, 1Password, Firefox, Neovim, Starship)
    WingetManifest    = '../../modules/windows/winget/packages.work.yaml'

    # PowerShell DSC configurations to compile and apply (maps USD 308 S: and W: drives)
    DscConfigurations = @(
        '../../modules/windows/dsc/FileShares.ps1'
    )

    # Declarative Windows Registry scripts (reveals file extensions & hidden files, left-aligns taskbar)
    RegistryScripts   = @(
        '../../modules/windows/registry/explorer-tweaks.ps1'
    )
}
