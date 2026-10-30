# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-btrfs.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap — Phase 2):
#   Declarative Disko layout using Btrfs subvolumes ('@root', '@nix', '@home',
#   '@snapshots') with transparent zstd compression and noatime flags to maximize
#   Nix store I/O speed, deduplication, and atomic snapshot capabilities.
# ==============================================================================

{ device ? "/dev/nvme0n1", ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        inherit device;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  "@root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
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
