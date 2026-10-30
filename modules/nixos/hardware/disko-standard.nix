# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-standard.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides a deterministic single-disk GPT partitioning schema with a 512MB
#   FAT32 EFI System Partition ('/boot') and an Ext4 root filesystem ('/').
#   Accepts a customizable 'device' argument (defaults to '/dev/nvme0n1', or
#   '/dev/vda' on UTM/QEMU virtual machines).
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
