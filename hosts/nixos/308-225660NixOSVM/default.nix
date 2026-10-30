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

    # Unified Core NixOS Foundation (Project 19)
    ../../../modules/nixos/core/global.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/hardware/apple-keyboard.nix

    # Shared User & Developer Tools (1-to-1 Cross-Platform Modules)
    ../../../modules/shared/git.nix
    ../../../modules/shared/git-bug.nix
    ../../../modules/shared/tea.nix
    ../../../modules/shared/lazygit.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix
    ../../../modules/shared/security/yubikey-nordic.nix
    ../../../modules/shared/security/gpg.nix
    ../../../modules/shared/security/vaultwarden-client.nix
    ../../../modules/shared/storage/file-integrity-monitor.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY & HARDWARE PLATFORM
  # ----------------------------------------------------------------------------
  networking.hostName = "308-225660NixOSVM";
  nixpkgs.hostPlatform = "aarch64-linux";

  # Paravirtualized VirtIO Storage & Bus Drivers
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
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # ----------------------------------------------------------------------------
  # REMOTE MANAGEMENT VIA OPENSSH
  # ----------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ 22 ];

  users.users.jchambers = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINcOrpJmrhwkpgc1LB7dEkjDRFDthgbFra0XOqfAtAkL joshua@chambers-net.org"
    ];
  };

  system.stateVersion = "24.11";
}
