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

  # Network share definition
  fileSystems."/mnt/usd308synologynas" = {
    device = "//172.16.3.0/Backups/JoshBackups";
    fsType = "cifs";
    options = [
      "credentials=admin308"
      "uid=1000"
      "gid=1000"
      "x-systemd.automount"
      "noauto"
      "x-systemd.idle-timeout=300"
      "x-systemd.device-timeout=5s"
      "_netdev"
    ];
  };
}
