# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-standard.nix (Standard Ext4)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides a classic, rock-solid single-disk GPT partitioning schema:
#     - 512MB FAT32 EFI System Partition (ESP) mounted at '/boot'.
#     - Single Ext4 root filesystem mounted at '/' taking 100% of remaining disk space.
#   Accepts a customizable 'device' argument (defaults to '/dev/nvme0n1' for physical
#   NVMe SSDs, or '/dev/vda' / '/dev/sda' for QEMU/UTM virtual machines).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   While Btrfs offers advanced features like subvolumes and transparent compression,
#   Ext4 (Fourth Extended Filesystem) is the most battle-tested, universally reliable
#   filesystem in the Linux world.
#   - For simple virtual machines, laboratory computers, or users who want a
#     traditional, zero-maintenance storage layout, this module provides the
#     standard partitioning blueprint without the complexity of subvolumes.
#   - Disko handles formatting the FAT32 boot partition and Ext4 root automatically
#     during system installation.
#
# >>> CRITICAL CAUTION: DISK ERASURE WARNING <<<
#   Applying this Disko configuration (via 'disko --mode disko' or during 'nixos-install')
#   will COMPLETELY WIPE AND IRREVERSIBLY ERASE the target drive (default: /dev/nvme0n1)!
#   All existing operating systems, files, and partitions on the drive will be lost.
#   Always verify the target device path before executing!
# ==============================================================================

{ device ? "/dev/nvme0n1", ... }:

{
  disko.devices = {
    disk = {
      # Target storage device
      main = {
        type = "disk";
        inherit device;
        content = {
          # Standard GUID Partition Table
          type = "gpt";
          partitions = {

            # ------------------------------------------------------------------
            # Partition 1: EFI System Partition (ESP)
            # Holds the systemd-boot EFI binary and kernel images.
            # ------------------------------------------------------------------
            ESP = {
              type = "EF00"; # Standard UEFI partition type
              size = "512M"; # 512 megabytes
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Strict permissions: only root can access /boot files
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };

            # ------------------------------------------------------------------
            # Partition 2: Primary Ext4 Linux Filesystem
            # Classic, robust Linux filesystem spanning the remainder of the drive.
            # ------------------------------------------------------------------
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };

          };
        };
      };
    };
  };
}
