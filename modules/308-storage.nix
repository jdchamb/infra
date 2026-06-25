{ config, pkgs, ... }:

{
  # Ensure the system has CIFS utilities available to the kernel
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # --- Systemd Mount Configurations for USD 308 Infrastructure
  fileSystems = {

    # 1. Local Network Storage
    "/home/josh/Shares/WorkStorage" = {
      device = "//172.16.3.0/Backups/JoshBackups"; # <-- Replace with the actual host IP
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/smb-secrets"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

    # 2. Cloud Storage Gateway
    "/home/josh/Shares/CloudStorage" = {
      device = "//cloud-storage.usd308.com"; # <-- Adjust destination share name if different
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/smb-secrets"
        "uid=1000"
        "gid=100"
        "file_mode=0755"
        "dir_mode=0755"
        "vers=3.0"
        "iocharset=utf8"
      ];
    };

    # 3. PDQ Server Main Share
    "/home/josh/Shares/PDQServer" = {
      device = "//pdq.usd308.com/"; # <-- Adjust destination share name if different
      fsType = "cifs";
      options = [
        "x-systemd.mount-timeout=30"
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        "credentials=/etc/nixos/secrets/smb-secrets"
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
