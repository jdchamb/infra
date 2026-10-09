@{
    NodeName          = 'wrk-win01'
    Role              = 'Workstation'
    WingetManifest    = '../../modules/windows/winget/packages.work.yaml'
    DscConfigurations = @(
        '../../modules/windows/dsc/FileShares.ps1'
    )
    RegistryScripts   = @(
        '../../modules/windows/registry/explorer-tweaks.ps1'
    )
}
