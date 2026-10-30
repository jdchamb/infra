# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/308-storage.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 18 — District SMB/CIFS Network Storage):
#   Mounts four core USD 308 district Windows file shares (WorkStorage, CloudStorage,
#   PDQ Software repository, and PDQ Automation scripts) directly into the Linux
#   filesystem under '/home/jchambers/Shares/' at boot.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In an enterprise or school district environment, files and installers live on
#   central Windows servers (using SMB/CIFS protocols).
#   Instead of manually connecting through a file manager GUI each time you boot,
#   this module instructs the Linux kernel and systemd to automatically mount
#   these shared network folders.
#   - 'cifs-utils' provides the kernel helper tools needed to speak Windows SMB.
#   - 'network-online.target' ensures the system does not try to mount network
#     drives until your Wi-Fi or Ethernet connection is fully established.
#   - Authentication credentials (username, password, domain) are read securely
#     from SOPS-encrypted files under '/etc/nixos/secrets/'.
#
# HOW TO USE:
#   - Importing this module mounts the shares automatically whenever network is active.
#   - Access the mounted directories in your terminal or file manager:
#       ls -la /home/jchambers/Shares/WorkStorage
#       ls -la /home/jchambers/Shares/CloudStorage
#       ls -la /home/jchambers/Shares/PDQServer/Software
#       ls -la /home/jchambers/Shares/PDQServer/Scripts
#   - Required credential files (decrypted by sops-nix):
#       /etc/nixos/secrets/308-admin308
#       /etc/nixos/secrets/308-adminjc
#     (Format: username=<user>\npassword=<pass>\ndomain=<domain>)
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # System Packages: CIFS/SMB Utilities
  # cifs-utils provides 'mount.cifs', required by the kernel to mount Windows shares.
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    cifs-utils
  ];

  # --------------------------------------------------------------------------
  # Declarative Filesystem Mount Definitions
  # --------------------------------------------------------------------------
  fileSystems = {

    # 1. Local Network Backup Share (JoshBackups on internal server)
    "/home/jchambers/Shares/WorkStorage" = {
      # UNC path to the remote Windows / Samba server share
      device = "//172.16.3.0/Backups/JoshBackups";
      # Common Internet File System (SMB protocol)
      fsType = "cifs";
      options = [
        # Abort mount attempt after 30 seconds if the host or server is unreachable
        "x-systemd.mount-timeout=30"
        # Wait until the network stack has acquired an IP address before mounting
        "x-systemd.after=network-online.target"
        "x-systemd.requires=network-online.target"
        # File containing username and password (avoids plain text in /nix/store)
        "credentials=/etc/nixos/secrets/308-admin308"
        # Map remote files to local user UID 1000 ('jchambers')
        "uid=1000"
        # Map remote files to local group GID 100 ('users')
        "gid=100"
        # Set Linux permission bits: 0755 = rwxr-xr-x for files and folders
        "file_mode=0755"
        "dir_mode=0755"
        # Use SMB protocol version 3.0 (modern, secure, high-performance)
        "vers=3.0"
        # Use UTF-8 character encoding for filenames with spaces or special symbols
        "iocharset=utf8"
      ];
    };

    # 2. Cloud Storage TSC Resource Gateway (District Documentation & Drivers)
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

    # 3. PDQ Deploy Server — Software Installer Repository (.msi, .exe packages)
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

    # 4. PDQ Deploy Server — PowerShell, Batch, and Shell Automation Scripts
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
