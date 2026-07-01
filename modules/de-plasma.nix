# ==============================================================================
# ROLE: Graphical Interface and Plasma Workspace Customizer Module
# WHAT GOES HERE AND WHY:
#   This file encapsulates your desktop environment configuration.
#   It contains system settings (X11/Wayland backends, SDDM greeters) alongside
#   plasma-manager configurations.
#
#   Instead of registering the whole Home Manager module engine itself, it hooks into the
#   existing 'home-manager.users.jchambers' attribute set. Nix merges this block with
#   your baseline 'core-home-manager.nix' settings at build time.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # --- 1. NixOS System-Level Display Management ---
  # Fires up the system services required to render a graphical workspace
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.enable = true;

  # Core graphical applications available to the desktop layer
  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kdf
    kdePackages.isoimagewriter
  ];

  # --- 2. Dynamic User Workspace Customization via Blended Module Sets ---
  # We tap directly into the global Home Manager engine definition context
  home-manager = {
    # Registers plasma-manager into the available user module options tree
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

    # Blends your custom panel widgets and workspace configuration straight
    # into your active jchambers user space environment.
    users.jchambers = { ... }: {
      programs.plasma = {
        enable = true;
        overrideConfig = true; # Forces clean state convergence on generation activation

        # --- Fixes Project 7 Theme Resets ---
        # Explicitly pins the visual identity so Plasma stops reverting to stock light mode
        workspace = {
          clickToActivate = true;
          lookAndFeel = "org.kde.breezedark.desktop";
          theme = "breeze-dark";
          colorScheme = "BreezeDark";
        };

        # --- Declarative Taskbar Panel & Widget Design Layout ---
        panels = [
          {
            location = "bottom";
            height = 40;

            widgets = [
              # Left-most Module: Interactive Menu Shell Launcher
              "org.kde.plasma.kickoff"

              # Center Module: Dynamic Window Tracking Taskbar
              "org.kde.plasma.icontasks"

              # Right-most Module: Real-time compact system monitoring graphs
              {
                name = "org.kde.plasma.systemmonitor";
                config = {
                  Appearance = {
                    "showTitle" = "false";
                    "faceId" = "org.kde.ksysguard.grid";
                  };
                  Sensors = {
                    "highPrioritySensors" = [
                      "cpu/all/usage"
                      "mem/physical/utilization"
                      "gpu/gpu0/usage"
                      "network/all/download"
                      "network/all/upload"
                      "disk/all/usedpercent"
                    ];
                    "labels" = [
                      "CPU"
                      "RAM"
                      "GPU"
                      "DL"
                      "UL"
                      "STR"
                    ];
                  };
                };
              }

              # System Workspace Status Tray and Digital Clock Engine
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
            ];
          }
        ];
      };

      # --- Fixes Project 22: Dolphin Compact View Settings ---
      # This forces Dolphin to render with the smallest possible text/icon layout
      # and matches the tight grid configuration from your target reference image.
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
        # Mode 1 forces "Icons View" layout dynamically with the tight dimensions above
        ViewMode=1
      '';
    };
  };
}
