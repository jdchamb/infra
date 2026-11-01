# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/m920q-01/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Resilient Homelab Storage Appliance — Lenovo M920q + SA120):
#   Host configuration for the Lenovo ThinkCentre M920q Tiny ("micro") paired
#   with a Lenovo ThinkServer SA120 12-Bay SAS DAS enclosure.
#
#   - Hardware Profile: Intel 8th/9th Gen Desktop CPU, Intel UHD 630 VA-API,
#     thermald thermal management, Intel Gigabit Ethernet, and LSI SAS HBA (mpt3sas).
#   - Boot Storage: Internal NVMe SSD (/dev/nvme0n1) via declarative Disko.
#   - Enclosure Health: Automated systemd SES service (sg3_utils) keeping the
#     SA120 DAS fans quiet and cool at level 2.
#   - Storage Engine: OpenZFS dual-vdev RAIDZ2 pool ('tank') across 12x 4TB
#     enterprise HDDs (2x 6-disk RAIDZ2 vdevs; ~32TB usable, double write/read
#     IOPS, and significantly faster resilver times under disk failures).
#   - Local Data Protection: Automated weekly scrubs for self-healing bit-rot repair,
#     paired with Sanoid automated hourly/daily/monthly local snapshot retention.
#   - Network File Sharing: Reusable hardened Samba service with shares for Data,
#     Media (guest read-only enabled), and Backups (authenticated jchambers vault).
#   - Application Isolation: Clean appliance base with Rootless Podman enabled,
#     ensuring future application services run strictly in quarantined OCI containers.
#
# HOW TO USE:
#   - Rebuild or switch to this host:
#       sudo nixos-rebuild switch --flake ~/src/infra#m920q-01
#   - Check ZFS pool health & status:
#       zpool status tank
#   - Check SA120 fan controller:
#       systemctl status lenovo-sa120-fanspeed.service
#   - Set initial Samba password for user 'jchambers':
#       sudo smbpasswd -a jchambers
# ==============================================================================

{ hostName ? "m920q-01", diskDevice ? "/dev/nvme0n1" }:

{ config, lib, pkgs, inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Declarative Disko Storage Architecture (Internal NVMe Boot Drive)
    # --------------------------------------------------------------------------
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = diskDevice; })

    # --------------------------------------------------------------------------
    # 2. Hardware Profile: Lenovo ThinkCentre M920q Tiny & SA120 SAS DAS
    # --------------------------------------------------------------------------
    ../../../modules/nixos/hardware/lenovo-m920q.nix

    # --------------------------------------------------------------------------
    # 3. Unified Global Baseline & Core Operating System Infrastructure
    # --------------------------------------------------------------------------
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/impermanence.nix

    # --------------------------------------------------------------------------
    # 4. Shared Developer & Operations Tools
    # --------------------------------------------------------------------------
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix

    # --------------------------------------------------------------------------
    # 5. Reusable Fleet NAS Storage & Hardened File Sharing Suite
    # --------------------------------------------------------------------------
    ../../../modules/nixos/services/nas.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY & NETWORKING
  # ----------------------------------------------------------------------------
  networking.hostName = hostName;

  # OpenZFS requires a unique 32-bit hostId (8-character hexadecimal)
  # Derived pseudo-randomly for m920q-01
  networking.hostId = "8425e349";

  # Ensure kernel is compatible with OpenZFS (Stable LTS kernel)
  boot.kernelPackages = pkgs.linuxPackages;

  # Ensure remote SSH administration is accessible
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
  networking.firewall.allowedTCPPorts = [ 22 ];

  # ----------------------------------------------------------------------------
  # HARDWARE & ACOUSTIC REGULATION
  # ----------------------------------------------------------------------------
  hardware.lenovo-sa120 = {
    fanControl = {
      enable = true;
      speed = 2; # Level 2: Whisper-quiet while keeping 12 drives under 38C
    };
  };

  # ----------------------------------------------------------------------------
  # REUSABLE NAS SERVICE DECLARATION
  # ----------------------------------------------------------------------------
  services.fleet.nas = {
    enable = true;
    poolName = "tank";
    mountPoint = "/tank";

    autoScrub = {
      enable = true;
      interval = "weekly";
    };

    sanoid = {
      enable = true;
      hourly = 24;
      daily = 7;
      weekly = 4;
      monthly = 12;
    };
  };

  # ----------------------------------------------------------------------------
  # FUTURE-PROOF CONTAINER SANDBOXING (Rootless Podman)
  # ----------------------------------------------------------------------------
  # Podman is enabled on the host so any future applications (e.g. Immich,
  # Jellyfin, Paperless) can run cleanly in quarantined rootless containers
  # without cluttering bare-metal or touching storage secrets.
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ----------------------------------------------------------------------------
  # STATE VERSION
  # ----------------------------------------------------------------------------
  system.stateVersion = "24.11";
}
