{ config, pkgs, inputs, ... }:

{
  imports = [
    # --- Disko Partitioning Layout ---
    (import ../../../modules/nixos/hardware/disko-standard.nix { device = "/dev/vda"; })

    # --- Common Fleet Modules ---
    ../../../modules/common/fonts.nix
    ../../../modules/common/cachix.nix
    ../../../modules/common/sops-tools.nix

    # --- Shared User / Dev Modules ---
    ../../../modules/shared/git.nix
    ../../../modules/shared/vim.nix
    ../../../modules/shared/neovim.nix
    ../../../modules/shared/zellij.nix
    ../../../modules/shared/ghostty.nix

    # --- Core NixOS Foundation ---
    ../../../modules/nixos/core/system.nix
    ../../../modules/nixos/core/boot.nix
    ../../../modules/nixos/core/network.nix
    ../../../modules/nixos/core/user.nix
    ../../../modules/nixos/core/audio.nix
    ../../../modules/nixos/hardware/hw-utils.nix
  ];

  # Host Identification
  networking.hostName = "vm-mac-utm01";

  # Hardware Platform & Storage Controller (VirtIO)
  nixpkgs.hostPlatform = "aarch64-linux";
  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_blk" "virtio_scsi" "xhci_pci" "usbhid" ];

  # UTM / QEMU Integration Utilities (Clipboard sharing & resolution adjustments)
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Do NOT change stateVersion
  system.stateVersion = "24.11";
}
