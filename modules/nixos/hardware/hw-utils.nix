# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/hw-utils.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Equips workstations and live recovery ISOs with low-level bus probing tools
#   (PCIe, USB, DMI/SMBIOS), NIST/DoD-compliant drive wiping utilities (nwipe,
#   nvme-cli, sedutil, hdparm), and userspace tools for every major filesystem
#   encountered in heterogeneous Windows/macOS/Linux fleet environments.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- 1. Hardware Bus & Firmware Diagnostics ---
    pciutils        # Low-level PCI bus inspection (provides 'lspci')
    usbutils        # Low-level USB bus inspection (provides 'lsusb')
    dmidecode       # DMI/SMBIOS table decoder (BIOS/serial/asset tag inspection)
    hwinfo          # Comprehensive hardware probing utility
    hdparm          # Low-level SATA/IDE device tuning and ATA Secure Erase
    smartmontools   # S.M.A.R.T. storage health monitoring ('smartctl')
    lm_sensors      # Thermal sensor and fan speed monitoring ('sensors')

    # --- 2. Storage Partitioning & Cryptographic Sanitization ---
    parted          # GNU partition editor
    gptfdisk        # Advanced GUID Partition Table manipulation ('gdisk', 'sgdisk')
    nvme-cli        # NVMe drive management, namespace inspection, and crypto-sanitize
    nwipe           # NCurses fork of DBAN for multi-drive secure wiping
    scrub           # Writes patterns on magnetic/flash media to destroy data remnants
    sedutil         # TCG OPAL 2.0 self-encrypting drive (SED) management ('sedutil-cli')

    # --- 3. Cross-Platform Filesystem Utilities ---
    exfatprogs      # Modern exFAT creation, labeling, and repair
    ntfs3g          # Userspace NTFS read/write driver and repair utilities
    dosfstools      # Utilities for UEFI FAT16/FAT32 filesystems ('mkfs.vfat', 'fsck.vfat')
    xfsprogs        # XFS filesystem creation and maintenance utilities
    btrfs-progs     # Btrfs subvolume, scrub, and snapshot utilities
    cifs-utils      # SMB/CIFS mount helper for Windows/USD 308 network shares
    nfs-utils       # Network File System client/server mount utilities
  ];
}
