# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-btrfs.nix (Btrfs Storage)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap — Phase 2 Declarative Storage):
#   Defines a declarative Disko disk layout utilizing modern Btrfs subvolumes
#   ('@root', '@nix', '@home', '@snapshots') with transparent zstd compression
#   and 'noatime' mount options to maximize SSD endurance and I/O throughput.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is Disko? Traditionally, partitioning a hard drive requires running
#     interactive tools like 'fdisk' or 'gparted'. Disko turns disk partitioning
#     into declarative Nix code. When running the NixOS installer, Disko formats
#     and mounts all partitions automatically according to this exact specification.
#   - What is Btrfs? Btrfs (B-tree File System) is a modern Copy-on-Write (CoW)
#     filesystem for Linux. Instead of splitting a physical disk into rigid,
#     fixed-size partitions, Btrfs creates "subvolumes" that share the same free
#     pool of disk space dynamically.
#   - Subvolume Breakdown:
#       '@root' (mountpoint '/'): Contains the core operating system files.
#       '@nix' (mountpoint '/nix'): Holds the Nix store. Keeping it separate makes
#         backups cleaner.
#       '@home' (mountpoint '/home'): Holds user documents, code, and personal settings.
#       '@snapshots' (mountpoint '/.snapshots'): Dedicated location for atomic
#         filesystem rollback snapshots.
#   - 'compress=zstd': Files are compressed transparently in RAM before writing
#     to disk. Because CPUs decompress data much faster than flash storage reads it,
#     zstd compression actually makes your computer feel FASTER while saving 20-40% disk space.
#   - 'noatime': Disables writing an "access timestamp" every single time a file
#     is read, drastically reducing SSD write wear.
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
      # Primary system drive target
      main = {
        type = "disk";
        inherit device;
        content = {
          # Modern GUID Partition Table (required for UEFI systems)
          type = "gpt";
          partitions = {

            # ------------------------------------------------------------------
            # Partition 1: EFI System Partition (ESP)
            # Holds the UEFI systemd-boot bootloader, kernel, and initrd binaries.
            # ------------------------------------------------------------------
            ESP = {
              type = "EF00"; # Hex partition type for UEFI System Partition
              size = "512M"; # 512 megabytes (ample room for several kernels)
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # fmask/dmask=0077: Restrict /boot files so only root can read them
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };

            # ------------------------------------------------------------------
            # Partition 2: Btrfs Main Storage Pool
            # Occupies 100% of the remaining storage space on the drive.
            # ------------------------------------------------------------------
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                # '-f' forces creation even if an older filesystem signature exists
                extraArgs = [ "-f" ];

                # Declarative Btrfs subvolumes sharing the single storage pool
                subvolumes = {
                  # Root OS subvolume
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # Nix package store subvolume
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # User personal directories subvolume
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # Snapshot storage subvolume for system rollbacks
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };

          };
        };
      };
    };
  };
}
