# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/disko-impermanence.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 3):
#   Defines a GPT + UEFI + Btrfs subvolume partition table engineered for the
#   "Erase Your Darlings" stateless root architecture ('core/impermanence.nix'):
#     - '@root': Mounted at '/' (ephemeral root layer)
#     - '@nix': Mounted at '/nix' (persists the immutable Nix store & generations)
#     - '@persist': Mounted at '/persist' (persists explicitly declared state)
#     - '@log': Mounted at '/var/log' (persists systemd journal audit logs)
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
                  "@persist" = {
                    mountpoint = "/persist";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
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
