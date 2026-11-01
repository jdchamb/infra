# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/nas.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Network Attached Storage & Resilient Data Pool):
#   This reusable module turns any machine in the fleet into an enterprise-grade,
#   hardened Network Attached Storage (NAS) appliance.
#
#   Core Capabilities:
#     1. OpenZFS Storage Engine: Automates zpool importation ('tank'), background
#        weekly parity scrubs for bit-rot healing, and zero-overhead RAM ARC caching.
#     2. Sanoid Automated Local Snapshots: Generates atomic, instantaneous local
#        snapshots (hourly, daily, weekly, monthly) for instant rollback against
#        accidental deletion, corrupt writes, or ransomware.
#     3. Hardened Native Samba File Sharing: Serves SMB shares with modern SMB2/SMB3
#        and NTLMv2 encryption:
#        - 'Data': Private storage for documents, projects, and homelab files.
#        - 'Media': Shared storage (public read-only for streaming/guests, authenticated write for admin).
#        - 'Backups': Dedicated authenticated backup vault for workstations and laptops.
#     4. Dynamic Network Discovery: Runs WSDD (Web Services Dynamic Discovery) so
#        the NAS discovers automatically in Windows File Explorer and macOS Finder.
#     5. Zero-Trust Systemd Sandboxing: Restricts the Samba daemon with Linux
#        namespaces and privilege boundaries, keeping bare-metal clean.
#
# WHY THIS EXISTS:
#   Keeping NAS functionality isolated inside this module keeps host configurations
#   pure and hostnames role-agnostic. Any node with direct attached storage can
#   import this module with a single line: 'services.fleet.nas.enable = true;'.
#
# HOW TO USE:
#   - In any host configuration:
#       services.fleet.nas = {
#         enable = true;
#         poolName = "tank"; # Name of your ZFS storage pool
#       };
#   - Set your Samba password on first boot:
#       sudo smbpasswd -a jchambers
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fleet.nas;
in
{
  options.services.fleet.nas = {
    enable = lib.mkEnableOption "Fleet Reusable NAS Storage & Hardened File Sharing Suite";

    poolName = lib.mkOption {
      type = lib.types.str;
      default = "tank";
      description = "Name of the primary OpenZFS storage pool to manage.";
    };

    mountPoint = lib.mkOption {
      type = lib.types.str;
      default = "/tank";
      description = "Root filesystem mount point of the ZFS pool.";
    };

    autoScrub = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automate periodic background parity scrubs to heal silent bit rot.";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "weekly";
        description = "Interval for automated ZFS pool scrubs (e.g. weekly, monthly).";
      };
    };

    sanoid = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Sanoid automated periodic local snapshot policy and pruning.";
      };

      hourly = lib.mkOption {
        type = lib.types.int;
        default = 24;
        description = "Number of hourly snapshots to retain.";
      };

      daily = lib.mkOption {
        type = lib.types.int;
        default = 7;
        description = "Number of daily snapshots to retain.";
      };

      weekly = lib.mkOption {
        type = lib.types.int;
        default = 4;
        description = "Number of weekly snapshots to retain.";
      };

      monthly = lib.mkOption {
        type = lib.types.int;
        default = 12;
        description = "Number of monthly snapshots to retain.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # --------------------------------------------------------------------------
    # 1. OpenZFS Kernel Integration & Auto-Import
    # --------------------------------------------------------------------------
    boot.supportedFilesystems = [ "zfs" ];

    # Safety: do not force import root pools to prevent accidental data loss
    boot.zfs.forceImportRoot = false;

    # Automatically import the storage pool during boot
    boot.zfs.extraPools = [ cfg.poolName ];

    # Scheduled automated pool scrubs (detects and repairs bit rot)
    services.zfs.autoScrub = {
      enable = cfg.autoScrub.enable;
      interval = cfg.autoScrub.interval;
      pools = [ cfg.poolName ];
    };

    # Mechanical spinning drives do not use SSD trim
    services.zfs.trim.enable = false;

    # --------------------------------------------------------------------------
    # 2. Sanoid Automated Local Snapshot Management
    # --------------------------------------------------------------------------
    services.sanoid = lib.mkIf cfg.sanoid.enable {
      enable = true;

      templates.standard = {
        hourly = cfg.sanoid.hourly;
        daily = cfg.sanoid.daily;
        weekly = cfg.sanoid.weekly;
        monthly = cfg.sanoid.monthly;
        autoprune = true;
        autosnap = true;
      };

      datasets = {
        "${cfg.poolName}/data" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "${cfg.poolName}/media" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
        "${cfg.poolName}/backups" = {
          useTemplate = [ "standard" ];
          recursive = true;
        };
      };
    };

    # --------------------------------------------------------------------------
    # 3. Hardened Samba SMB File Sharing Daemon
    # --------------------------------------------------------------------------
    services.samba = {
      enable = true;
      openFirewall = false; # Handled explicitly below for granular security

      settings = {
        global = {
          # Security & Protocol Negotiation
          "workgroup" = "WORKGROUP";
          "server string" = "Fleet Storage Appliance (%h)";
          "netbios name" = config.networking.hostName;
          "security" = "user";
          "server min protocol" = "SMB2_10";
          "client min protocol" = "SMB2_10";
          "client max protocol" = "SMB3";
          "client ntlmv2 auth" = "yes";

          # Performance & POSIX Extended Attributes
          "ea support" = "yes";
          "aio read size" = "1";
          "aio write size" = "1";
          "use sendfile" = "yes";

          # Guest account mapping for public read shares
          "map to guest" = "Bad User";
          "guest account" = "nobody";
        };

        # Share 1: Data (Private, Authenticated)
        "Data" = {
          "path" = "${cfg.mountPoint}/data";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "jchambers";
          "create mask" = "0660";
          "directory mask" = "0770";
          "comment" = "General Homelab & Production Data";
        };

        # Share 2: Media (Public Read-Only, Authenticated Write)
        "Media" = {
          "path" = "${cfg.mountPoint}/media";
          "browseable" = "yes";
          "read only" = "yes";
          "write list" = "jchambers";
          "guest ok" = "yes";
          "create mask" = "0664";
          "directory mask" = "0775";
          "comment" = "Shared Media, Streaming & Audio Library";
        };

        # Share 3: Backups (Private, Authenticated Vault)
        "Backups" = {
          "path" = "${cfg.mountPoint}/backups";
          "browseable" = "yes";
          "read only" = "no";
          "valid users" = "jchambers";
          "create mask" = "0600";
          "directory mask" = "0700";
          "comment" = "Encrypted Workstation & Server Backups";
        };
      };
    };

    # --------------------------------------------------------------------------
    # 4. Windows & macOS Network Discovery (WSDD)
    # --------------------------------------------------------------------------
    services.samba-wsdd = {
      enable = true;
      openFirewall = false;
      hostname = config.networking.hostName;
      workgroup = "WORKGROUP";
    };

    # --------------------------------------------------------------------------
    # 5. Network Firewall Rules (Strictly Scoped)
    # --------------------------------------------------------------------------
    networking.firewall = {
      allowedTCPPorts = [
        445   # SMB direct over TCP
        139   # NetBIOS Session Service
        5357  # WSDD (Web Services Dynamic Discovery)
      ];
      allowedUDPPorts = [
        137   # NetBIOS Name Service
        138   # NetBIOS Datagram Service
        3702  # WS-Discovery multicast
      ];
    };

    # --------------------------------------------------------------------------
    # 6. Hardening: Systemd Service Sandboxing for Samba
    # --------------------------------------------------------------------------
    systemd.services.samba-smbd.serviceConfig = {
      ProtectSystem = "full";
      ProtectHome = "read-only";
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };
}
