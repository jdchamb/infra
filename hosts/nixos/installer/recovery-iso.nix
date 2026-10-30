# ==============================================================================
# HOST CONFIGURATION: hosts/nixos/installer/recovery-iso.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 1 & 20):
#   Constructs a full KDE Plasma 6 graphical rescue and provisioning ISO equipped
#   with hardware sanitization tools ('nwipe', 'nvme-cli', 'sedutil'), remote
#   desktop clients ('remmina', 'krdc'), automatic USD 308 CIFS resource mounting,
#   and zero-touch SSH/Git bootstrap automation ('core/bootstrap.nix').
# ==============================================================================

{ pkgs, modulesPath, inputs, ... }:

{
  imports = [
    # 1. Base channel profile required to construct a bootable graphical Plasma 6 ISO environment
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"

    # 2. Shared Base Platform & Zero-Touch Bootstrap Configurations (Projects 1 & 20)
    "${inputs.self}/modules/common/fonts.nix"
    "${inputs.self}/modules/common/cachix.nix"
    "${inputs.self}/modules/common/sops-tools.nix"
    "${inputs.self}/modules/shared/git.nix"
    "${inputs.self}/modules/shared/neovim.nix"
    "${inputs.self}/modules/nixos/core/system.nix"
    "${inputs.self}/modules/nixos/core/network.nix"
    "${inputs.self}/modules/nixos/core/user.nix"
    "${inputs.self}/modules/nixos/core/bootstrap.nix"
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"

    # 3. Graphical Fleet Recovery & Remote Support Applications (1-to-1 Modules)
    "${inputs.self}/modules/nixos/apps/remmina.nix"
    "${inputs.self}/modules/nixos/apps/krdc.nix"
    "${inputs.self}/modules/nixos/apps/partitionmanager.nix"
    "${inputs.self}/modules/nixos/apps/filelight.nix"
  ];

  # Override global profile states to enforce strict open-source package parameters on live rescue media
  nixpkgs.config.allowUnfree = false;

  # --- Automated 308-Storage Mount point definition ---
  fileSystems."/mnt/308-storage" = {
    device = "//cloud-storage.usd308.com/Resources/TSC";
    fsType = "cifs";
    options = let
      automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
    in [ "${automount_opts},guest,uid=1000,gid=100" ];
  };
}
