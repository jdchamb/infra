# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/dolphin.nix (KDE Dolphin File Manager)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 9 & 22 — 1-to-1 Module for Dolphin):
#   Installs KDE Dolphin with KIO network/archive helpers and injects a declarative
#   '.config/dolphinrc' profile:
#     - Project 9: Enforces Details/List mode by default, 16px compact icon grids,
#       expandable folder trees, and optimized preview cache thresholds
#       ('MaximumRemoteSize = 0') so browsing remote USD 308 CIFS/SMB shares
#       ('308-storage.nix') is instant and never hangs waiting for thumbnails.
#     - Project 22: High-density 8pt JetBrains Mono typography across all file views.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is Dolphin? Dolphin is widely regarded as the most versatile file manager
#     available on Linux. It features split-panel views (press F3), integrated terminal
#     drawers (press F4), tabs, and native support for network protocols.
#   - Why 'kio-extras'? KIO (KDE Input/Output) is the abstraction framework that allows
#     Dolphin to open zip/tar/iso archives as if they were regular folders, and browse
#     remote file protocols like 'smb://', 'sftp://', and 'fish://'.
#   - Why disable remote previews ('MaximumRemoteSize=0')? When you browse a Windows
#     network share containing thousands of files or heavy video/ISO installers,
#     default file managers try to download every single file over Wi-Fi just to create
#     a tiny preview thumbnail. This causes severe network lag and freezes the GUI.
#     Setting 'MaximumRemoteSize = 0' completely disables remote thumbnail generation,
#     ensuring that opening network shares is instantaneous.
#   - 'EditableUrl = true' & 'ShowFullPath = true': Displays the true UNIX filesystem
#     path in the address bar (e.g. '/home/jchambers/Shares/...') instead of ambiguous
#     graphical breadcrumbs.
#
# HOW TO USE:
#   - Launch Dolphin from terminal: 'dolphin'
#   - Launch Dolphin in a specific folder: 'dolphin /home/jchambers/Shares'
#   - Toggle Split View: Press 'F3'
#   - Toggle embedded terminal drawer: Press 'F4'
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System Packages: Dolphin & KIO Framework
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    kdePackages.dolphin     # Full KDE Dolphin file manager application
    kdePackages.kio-extras  # Plugins for network share browsing and archive inspection
  ];

  # --------------------------------------------------------------------------
  # 2. Declarative User Configuration (Home Manager for 'jchambers')
  # Injects ~/.config/dolphinrc to enforce view layouts, cache sizes, and fonts.
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {
    home.file.".config/dolphinrc".text = ''
      [CompactView]
      Font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      IconSize=16
      PreviewSize=16
      MaximumTextLines=1

      [DetailsMode]
      # Allow clicking small arrows next to folders to expand their contents inline
      ExpandableFolders=true
      Font=JetBrains Mono,8,-1,5,50,0,0,0,0,0
      IconSize=16
      PreviewSize=16
      SidePadding=0

      [General]
      # Treat .zip and .tar archives as navigable folders
      BrowseThroughArchives=true
      # Show real editable path in the location bar by default
      EditableUrl=true
      # Show instant search filter bar
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
      # Disable thumbnail generation over remote CIFS/SMB shares to prevent UI lag (Project 9)
      MaximumRemoteSize=0
      # Limit local thumbnail generation to files smaller than 10MB
      MaximumSize=10485760
      Plugins=directorythumbnail,imagethumbnail,jpegthumbnail,svgthumbnail

      [Search]
      Location=Everywhere

      [TransientPositions]
      IconSize=16

      [Views arrangements]
      # ViewMode=1 forces Details (table) view across all directories
      ViewMode=1
    '';
  };
}
