# ==============================================================================
# HARDWARE SCAN PROFILE: hosts/nixos/308-222242/hardware.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Hardware-specific kernel modules, disk partition UUIDs, and CPU microcode
#   settings for '308-222242' (Primary Bare-Metal Linux Workstation).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When NixOS boots, it needs to know TWO things that are unique to the physical
#   motherboard and hard drive inside this specific computer:
#     1. Which kernel storage/USB drivers ('availableKernelModules') must be
#        loaded into the initial RAM disk ('initrd') so the kernel can read the
#        SSD before the root filesystem is even mounted.
#     2. The exact Globally Unique Identifiers ('/dev/disk/by-uuid/...') of the
#        physical partitions for '/' (root) and '/boot' (EFI System Partition).
#   Using UUIDs instead of device names like '/dev/sda1' or '/dev/nvme0n1p2'
#   guarantees the machine will still boot even if you plug in extra drives or
#   move SATA cables to different motherboard ports!
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
  # 2. PHYSICAL DISK PARTITION MOUNTS (By Cryptographic/Filesystem UUID)
  # ----------------------------------------------------------------------------
  # Primary Linux Root Filesystem (ext4)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/45ed33f8-dd8c-49f6-bbaf-e24406716bc6";
    fsType = "ext4";
  };

  # UEFI System Partition (/boot formatted as FAT32/vfat)
  # 'fmask=0077' and 'dmask=0077' restrict /boot permissions to root-only (0700)
  # so unprivileged users cannot tamper with kernel images or systemd-boot entries.
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/F07A-954D";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # No dedicated disk swap partition (RAM is sufficient)
  swapDevices = [ ];

  # ----------------------------------------------------------------------------
  # 3. CPU ARCHITECTURE & INTEL MICROCODE UPDATES
  # ----------------------------------------------------------------------------
  # Target 64-bit x86 Linux binaries
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Automatically patch Intel CPU firmware at early boot to fix hardware errata and security vulnerabilities
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
