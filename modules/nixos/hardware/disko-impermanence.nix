# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-impermanence.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 3 — Stateless Impermanence Disko Layout):
#   Defines a declarative GPT + UEFI + Btrfs subvolume partition table specifically
#   engineered for the "Erase Your Darlings" stateless root architecture
#   (configured in 'modules/nixos/core/impermanence.nix'):
#     - '@root': Mounted at '/' (ephemeral root layer wiped or rolled back on reboot)
#     - '@nix': Mounted at '/nix' (persists the immutable Nix store & generations)
#     - '@persist': Mounted at '/persist' (persists explicitly declared state)
#     - '@log': Mounted at '/var/log' (persists systemd journal audit logs)
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When using impermanence (stateless root), you need the underlying filesystem
#   to cleanly separate files that should disappear from files that must be kept:
#     1. Ephemeral Root ('@root'): Contains temporary files created by the OS.
#        On reboot, this subvolume is either restored from a blank snapshot or
#        recreated, ensuring zero configuration drift.
#     2. Nix Store ('@nix'): Nix packages are read-only and immutable. They live
#        in their own subvolume so they survive reboots without cluttering the root.
#     3. Persistent Storage ('@persist'): Stores files you explicitly want to keep
#        (passwords, Wi-Fi keys, Age decryption keys, user documents).
#     4. System Logs ('@log'): System journals are saved here so if a crash occurs,
#        you can inspect the boot logs even after the root filesystem resets.
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
      # Target storage drive definition
      main = {
        type = "disk";
        inherit device;
        content = {
          # GPT partition table for modern UEFI firmware
          type = "gpt";
          partitions = {

            # ------------------------------------------------------------------
            # Partition 1: EFI System Partition (ESP)
            # Holds the UEFI systemd-boot bootloader, kernel, and initrd binaries.
            # ------------------------------------------------------------------
            ESP = {
              type = "EF00"; # UEFI partition type
              size = "512M"; # 512MB bootloader space
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                # Strict permissions: only root can access /boot files
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };

            # ------------------------------------------------------------------
            # Partition 2: Btrfs Main Storage Pool
            # Spans 100% of the drive, subdivided into functional subvolumes.
            # ------------------------------------------------------------------
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Force filesystem creation

                subvolumes = {
                  # Ephemeral root: wiped or rolled back to blank state on reboot
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # Persistent Nix store: holds installed packages and system derivations
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # Permanent state storage: holds bind-mounted secrets, SSH keys, user data
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };

                  # Persistent audit logs: preserves systemd journal entries across root resets
                  "@log" = {
                    mountpoint = "/var/log";
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
