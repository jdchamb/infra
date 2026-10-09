{ config, pkgs, ... }:

{
  # Ensure the system has CIFS utilities available to the kernel
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # --- Systemd Mount Configurations for USD 308 Infrastructure
  fileSystems = {

    # 1. Local Network Storage
    "/home/jchambers/Shares/WorkStorage" = {
      device = "//172.16.3.0/Backups/JoshBackups";
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/308-admin308"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

    # 2. Cloud Storage Gateway
    "/home/jchambers/Shares/CloudStorage" = {
      device = "//cloud-storage.usd308.com/Resources/TSC";
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/308-adminjc"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

    # 3. PDQ Server - Software Repository
    "/home/jchambers/Shares/PDQServer/Software" = {
      device = "//pdq.usd308.com/Software";
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/308-adminjc"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

    # 4. PDQ Server - Automation Scripts
    "/home/jchambers/Shares/PDQServer/Scripts" = {
      device = "//pdq.usd308.com/Scripts"; # <-- Double check if this share name matches exactly on the server
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/308-adminjc"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

  };
}
