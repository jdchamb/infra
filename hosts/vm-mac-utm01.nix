{ config, pkgs, inputs, ... }:

{
  imports = [

    # --- Disko Partitioning Layout ---
  "${inputs.self}/modules/hw-disko-standard.nix { device = "/dev/vda"; })

    # --- Core Base Modules ---
    "${inputs.self}/modules/core-system.nix"
    "${inputs.self}/modules/core-boot.nix"
    "${inputs.self}/modules/core-network.nix"
    "${inputs.self}/modules/core-user.nix"
    "${inputs.self}/modules/core-audio.nix"
    "${inputs.self}/modules/core-fonts.nix"
    "${inputs.self}/modules/core-cachix.nix"
    "${inputs.self}/modules/core-hw-utils.nix"

    # --- Graphical & Terminal Tools ---
    "${inputs.self}/modules/app-ghostty.nix"
    "${inputs.self}/modules/dev-git.nix"
    "${inputs.self}/modules/dev-vim.nix"
    "${inputs.self}/modules/dev-neovim.nix"
    "${inputs.self}/modules/dev-zellij.nix"
    "${inputs.self}/modules/sops-tools.nix"
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
