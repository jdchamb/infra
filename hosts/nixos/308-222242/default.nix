# ==============================================================================
# HOST CONFIGURATION: 308-222242 (Primary Workstation Node)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Primary bare-metal Linux production workstation for Joshua Chambers.
#   - Architecture: x86_64-linux (Intel Core / KVM)
#   - Operating System: NixOS Unstable
#   - Storage Layout: Managed in ./hardware.nix (ext4 root + vfat EFI)
#   - Secrets Management: SOPS / Age decryption into volatile tmpfs (/run/secrets)
#   - Desktop Environments: Choice of Wayland compositors (Hyprland, Niri, Sway)
#   - Network Storage: Auto-mounting USD 308 CIFS/SMB storage shares
#
# OPERATIONAL RUNBOOK FOR SUCCESSORS:
#   - To apply changes on this workstation:
#       rebuild
#     (which executes: sudo nixos-rebuild switch --flake ~/src/infra#308-222242)
#   - To test changes before committing:
#       rebuild test
#   - To roll back a broken generation: Reboot and select a prior generation in GRUB/systemd-boot.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # MODULE COMPOSITION (Building Blocks)
  # ----------------------------------------------------------------------------
  imports = [
    # Upstream Secret Decryption Engine (SOPS-Nix)
    inputs.sops-nix.nixosModules.sops

    # Hardware Layer (Kernel modules, disk UUIDs, CPU microcode)
    ./hardware.nix

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

    # Core NixOS Foundation (Kernel, bootloader, users, networking, audio, printing)
    ../../../modules/nixos/core/system.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/network.nix
    ../../../modules/nixos/core/user.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/core/printing.nix
    ../../../modules/nixos/core/sops.nix
    ../../../modules/nixos/hardware/hw-utils.nix

    # Graphical Login Manager & Wayland Compositors
    ../../../modules/nixos/desktop/greetd.nix
    ../../../modules/nixos/desktop/hyprland.nix
    ../../../modules/nixos/desktop/niri.nix
    ../../../modules/nixos/desktop/sway.nix

    # Production Workstation Applications
    ../../../modules/nixos/apps/firefox.nix
    ../../../modules/nixos/apps/remmina.nix
    ../../../modules/nixos/apps/digikam.nix
    ../../../modules/nixos/apps/apple-tools.nix
    ../../../modules/nixos/apps/kate.nix
    ../../../modules/nixos/apps/dolphin.nix
    ../../../modules/nixos/apps/partitionmanager.nix
    ../../../modules/nixos/apps/filelight.nix
    ../../../modules/nixos/apps/kdf.nix
    ../../../modules/nixos/apps/isoimagewriter.nix

    # Infrastructure Services & Network Shares
    ../../../modules/nixos/services/samba.nix
    ../../../modules/nixos/services/308-storage.nix
  ];

  # ----------------------------------------------------------------------------
  # HOST IDENTITY
  # ----------------------------------------------------------------------------
  networking.hostName = "308-222242";

  # NixOS State Version: Determines backward compatibility defaults for stateful data.
  # Do NOT change this value without reading the release notes.
  system.stateVersion = "24.11";
}
