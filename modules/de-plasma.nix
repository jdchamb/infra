{ config, pkgs, inputs, ... }:

{
  # --- Core Plasma 6 System Service Activation
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    kdePackages.filelight
    kdePackages.kdf
  ];

# --- Declarative Taskbar Panel and System Monitor Configuration
  home-manager = {
    # Fixes the evaluation warning by using the updated upstream module name mapping
    sharedModules = [ inputs.plasma-manager.homeModules.plasma-manager ];

    users.jchambers = { ... }: {
      programs.plasma = {
        enable = true;
        overrideConfig = true; # Force matching declarative state on system activation

        panels = [
          {
            location = "bottom";
            height = 40;

            widgets = [
              # Left Side: Launcher
              "org.kde.plasma.kickoff"

              # Center: Window Tracking Task Manager
              "org.kde.plasma.icontasks"

              # Right Side: Integrated Compact Performance Sensors
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

              # End Elements: Tray & Clock
              "org.kde.plasma.systemtray"
              "org.kde.plasma.digitalclock"
            ];
          }
        ];
      };
    };
  };
}
