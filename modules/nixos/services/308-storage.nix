# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/308-storage.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 18):
#   Mounts the four core USD 308 SMB/CIFS infrastructure shares ('WorkStorage',
#   'CloudStorage', 'PDQServer/Software', and 'PDQServer/Scripts') at the kernel
#   level using explicit systemd 'network-online.target' ordering and SOPS-decrypted
#   credential symlinks ('/etc/nixos/secrets/308-adminjc' and '308-admin308').
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Ensure CIFS kernel mount helpers are present on the system PATH
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # 2. Systemd CIFS Mount Definitions for USD 308 Infrastructure
  fileSystems = {

    # Local Network Backup Storage
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

    # Cloud Storage TSC Resource Gateway
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

    # PDQ Deploy Server — Software Installer Repository
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

    # PDQ Deploy Server — PowerShell & Batch Automation Scripts
    "/home/jchambers/Shares/PDQServer/Scripts" = {
      device = "//pdq.usd308.com/Scripts";
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
