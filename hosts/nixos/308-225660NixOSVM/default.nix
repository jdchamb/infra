# ==============================================================================
# HOST CONFIGURATION: 308-225660NixOSVM (Apple Silicon UTM/VZ Virtual Machine)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Lightweight, paravirtualized NixOS guest running locally on the MacBook.
#   - Architecture: aarch64-linux (Native ARM64 execution on Apple Silicon)
#   - Hypervisor: Apple Virtualization.framework (via UTM or direct VZ runner)
#   - Storage Layout: Declarative Disko partitioning on virtual disk (/dev/vda)
#   - Integration: QEMU guest agent for time-sync/shutdowns + SPICE agent for clipboard
#   - Remote Management: SSH server on port 22 with authorized public key
#
# OPERATIONAL RUNBOOK FOR SUCCESSORS:
#   - To apply updates inside this VM:
#       rebuild
#     (which executes: sudo nixos-rebuild switch --flake ~/src/infra#308-225660NixOSVM)
#   - To connect from the host Mac:
#       ssh jchambers@<vm-ip-or-hostname>
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # MODULE COMPOSITION (Building Blocks)
  # ----------------------------------------------------------------------------
  imports = [
    # Declarative Disko Layout: Automates formatting & mounting /dev/vda
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = "/dev/vda"; })

    # Common Fleet Modules (Fonts, binary caches, secrets CLI)
    ../../../modules/common/fonts.nix
    ../../../modules/common/cachix.nix
    ../../../modules/common/sops-tools.nix

    # Shared User & Developer Tools (Cross-Platform)
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix
    ../../../modules/shared/security/yubikey-nordic.nix

    # Core NixOS Foundation
    ../../../modules/nixos/core/system.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/network.nix
    ../../../modules/nixos/core/user.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/hardware/hw-utils.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY & HARDWARE PLATFORM
  # ----------------------------------------------------------------------------
  networking.hostName = "308-225660NixOSVM";
  nixpkgs.hostPlatform = "aarch64-linux";

  # Paravirtualized VirtIO Storage & Bus Drivers
  # These kernel modules allow the Linux guest to talk directly to Apple's VZ hypervisor
  # with zero hardware emulation overhead.
  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "xhci_pci"
    "usbhid"
  ];

  # ----------------------------------------------------------------------------
  # GUEST-HOST INTEGRATION UTILITIES
  # ----------------------------------------------------------------------------
  # Allows host to signal graceful shutdowns, resize guest resolution, and sync clock
  services.qemuGuest.enable = true;

  # SPICE agent: Enables seamless two-way clipboard sharing between macOS and VM
  services.spice-vdagentd.enable = true;

  # ----------------------------------------------------------------------------
  # REMOTE MANAGEMENT VIA OPENSSH
  # ----------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password"; # Security: Require key-based root login
      PasswordAuthentication = true;        # User password fallback allowed
    };
  };

  # Open SSH port 22 in the firewall
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Pre-authorize primary user's SSH key for passwordless terminal access
  users.users.jchambers = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcOrpJmrhwkpgc1LB7dEkjDRFDthgbFra0XOqfAtAkL joshua@chambers-net.org"
    ];
  };

  # NixOS State Version: Determines backward compatibility defaults for stateful data.
  system.stateVersion = "24.11";
}
