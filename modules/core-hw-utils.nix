{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Hardware Diagnostics
    pciutils    # Low-level PCI bus inspection (provides 'lspci') [cite: 8]
    usbutils    # Low-level USB bus inspection (provides 'lsusb') [cite: 8]
    dmidecode   # DMI/SMBIOS table decoder (BIOS info) [cite: 8]
    hwinfo      # Comprehensive hardware probing tool [cite: 8]

    # --- Storage Partitioning
    parted      # Standard CLI partition manipulator
    gptfdisk    # Advanced GUID Partition Table manipulation

    # --- Cross-Platform File Systems
    exfatprogs  # Modern kernel-space exFAT creation and repair
    ntfs3g      # Userspace NTFS read/write utilities
    dosfstools  # Utilities for FAT16/FAT32 file systems
    xfsprogs    # XFS layout and maintenance utilities
    btrfs-progs # Btrfs userspace tools and formatting
  ];
}
