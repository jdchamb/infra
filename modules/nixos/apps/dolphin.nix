# app-dolphin.nix
# ROLE: Core File Manager Package and Layout Optimization Module

{ pkgs, ... }: {
  # Install the file manager package at the system level
  environment.systemPackages = [ pkgs.kdePackages.dolphin ];

  # Inject your compact view presets straight into Home Manager's dotfile layer
  home-manager.users.jchambers = { ... }: {
    home.file.".config/dolphinrc".text = ''
      [CompactView]
      IconSize=16

      [IconsView]
      IconSize=16

      [MainWindow]
      MenuBar=Disabled
      ToolBarsMovable=Disabled

      [TransientPositions]
      IconSize=16

      [Views arrangements]
      ViewMode=1
    '';
  };
}
