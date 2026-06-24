{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Hardware Diagnostics
    pciutils    # Low-level PCI bus inspection (provides 'lspci')
    usbutils    # Low-level USB bus inspection (provides 'lsusb')
    dmidecode   # DMI/SMBIOS table decoder (BIOS info)
    hwinfo      # Comprehensive hardware probing tool
    hdparm      # Low-level SATA/IDE device tuning and hardware erasing

    # --- Storage Partitioning
    parted      # Standard CLI partition manipulator
    gptfdisk    # Advanced GUID Partition Table manipulation
    nvme-cli    # NVMe drive management and hardware sanitization
    nwipe       # Command line tool based on DBAN for secure wiping
    scrub       # Writes patterns on magnetic media to disrupt magnetic signatures
    sedutil     # TCG OPAL self-encrypting drive management

    # --- Cross-Platform File Systems
    exfatprogs  # Modern kernel-space exFAT creation and repair
    ntfs3g      # Userspace NTFS read/write utilities
    dosfstools  # Utilities for FAT16/FAT32 file systems
    xfsprogs    # XFS layout and maintenance utilities
    btrfs-progs # Btrfs userspace tools and formatting
  ];
}
