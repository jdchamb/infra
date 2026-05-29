{ config, pkgs, ... }:

{
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    };
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    kdePackages.partitionmanager
    kdePackages.filelight  # Visualizes disk space as a tree/sunburst
    kdePackages.kdf        # KDiskFree: shows disk usage and mount points
    ];
}

