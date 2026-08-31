{ config, pkgs, inputs, ... }:

{
  imports = [
    # --- Disko Partitioning Layout ---
    (import ../modules/hw-disko-standard.nix { device = "/dev/vda"; })

    # --- Core Base Modules ---
    ../modules/core-system.nix
    ../modules/core-boot.nix
    ../modules/core-network.nix
    ../modules/core-user.nix
    ../modules/core-audio.nix
    ../modules/core-fonts.nix
    ../modules/core-cachix.nix
    ../modules/core-hw-utils.nix

    # --- Graphical & Terminal Tools ---
    ../modules/app-ghostty.nix
    ../modules/dev-git.nix
    ../modules/dev-vim.nix
    ../modules/dev-neovim.nix
    ../modules/dev-zellij.nix
    ../modules/sops-tools.nix
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