# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/dolphin.nix (KDE Dolphin File Manager)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 9 & 22 — 1-to-1 Module for Dolphin):
#   Installs KDE Dolphin with KIO network/archive helpers and injects a
#   declarative '.config/dolphinrc' profile fulfilling:
#     - Project 9: Compact/Details default list view modes, 16px small icon grids,
#       disabled clutter toolbars, and optimized preview cache thresholds so browsing
#       remote SMB shares ('308-storage.nix') stays instantaneous.
#     - Project 22: Smallest crisp 8pt JetBrains Mono list typography.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Install Dolphin & KIO Extras (SMB/SFTP previews and archive browsing)
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin
    kdePackages.kio-extras
  ];

  # 2. Inject Declarative View, Cache, and Compact Typography Presets
  home-manager.users.jchambers = { ... }: {
    home.file.".config/dolphinrc".text = ''
      [CompactView]
      Font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      IconSize=16
      PreviewSize=16
      MaximumTextLines=1

      [DetailsMode]
      ExpandableFolders=true
      Font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      IconSize=16
      PreviewSize=16
      SidePadding=0

      [General]
      BrowseThroughArchives=true
      EditableUrl=true
      FilterBar=true
      GlobalViewProps=true
      ShowFullPath=true
      ShowFullPathInTitlebar=true
      ShowSpaceInfo=true
      ShowToolTips=false
      SortingChoice=CaseInsensitiveSorting
      SplitView=false

      [IconsMode]
      Font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      IconSize=16
      PreviewSize=32

      [KFileDialog Settings]
      Places Icons Auto-resize=false
      Places Icons Static Size=16

      [MainWindow]
      MenuBar=Disabled
      ToolBarsMovable=Disabled

      [PreviewSettings]
      # Limit local preview generation to files <= 10 MB and disable heavy remote
      # thumbnail generation over CIFS/SMB network mounts (Project 9 cache optimization)
      MaximumRemoteSize=0
      MaximumSize=10485760
      Plugins=directorythumbnail,imagethumbnail,jpegthumbnail,svgthumbnail

      [Search]
      Location=Everywhere

      [TransientPositions]
      IconSize=16

      [Views arrangements]
      # ViewMode=1 forces Details/List View globally across directories
      ViewMode=1
    '';
  };
}
