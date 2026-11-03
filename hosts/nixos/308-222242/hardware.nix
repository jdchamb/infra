# ==============================================================================
# HARDWARE SCAN PROFILE: hosts/nixos/308-222242/hardware.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Hardware-specific kernel modules and CPU microcode settings for
#   '308-222242' (Primary Bare-Metal Linux Workstation).
#   Disk partitioning and mounts ('/' and '/boot') are managed declaratively
#   by Disko ('modules/nixos/hardware/disko-standard.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When NixOS boots, it needs to know which kernel storage/USB drivers
#   ('availableKernelModules') must be loaded into the initial RAM disk ('initrd')
#   so the kernel can read the NVMe/SATA SSD before the root filesystem is mounted,
#   as well as whether to apply Intel CPU microcode patches.
# ==============================================================================

{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    # Pulls in default fallback firmware rules for hardware not covered by mainlined drivers
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ----------------------------------------------------------------------------
  # 1. KERNEL & INITRD HARDWARE DRIVERS
  # ----------------------------------------------------------------------------
  # Drivers packed into the early-boot RAM disk (USB 3.0 XHCI, SATA AHCI, NVMe, USB keyboards/drives)
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];

  # Load Intel hardware virtualization ('kvm-intel') so QEMU/KVM virtual machines run at native CPU speed
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # ----------------------------------------------------------------------------
  # 2. CPU ARCHITECTURE & INTEL MICROCODE UPDATES
  # ----------------------------------------------------------------------------
  # Target 64-bit x86 Linux binaries
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Automatically patch Intel CPU firmware at early boot to fix hardware errata and security vulnerabilities
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
