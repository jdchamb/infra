# modules/hw-disko-standard.nix
{
  disko.devices = {
    disk = {
      # Target the primary system drive dynamically
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # 1. The Boot Partition (ESP)
            ESP = {
              type = "EF00"; # EFI System Partition type code
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0077" "dmask=0077" ];
              };
            };
            # 2. The Core Root Partition
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
