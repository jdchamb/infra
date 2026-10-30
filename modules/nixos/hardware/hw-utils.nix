# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/hw-utils.nix (Hardware & Disk Toolkit)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Equips all workstations, servers, and live recovery ISOs with an exhaustive
#   hardware diagnostic, storage sanitization, and cross-platform filesystem toolkit:
#     - Low-level motherboard, PCIe, USB, and SMBIOS firmware probing utilities.
#     - NIST SP 800-88 and DoD-compliant storage sanitization tools (nwipe, nvme-cli,
#       sedutil, hdparm, scrub) for secure computer decommissioning and drive re-use.
#     - Userspace filesystem drivers and repair binaries for all major formats
#       encountered across Windows, macOS, and Linux fleet environments (NTFS, exFAT,
#       FAT32, Btrfs, XFS, CIFS, NFS).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When maintaining a heterogeneous school district or lab fleet, technicians
#   frequently encounter broken drives, mystery USB peripherals, unknown motherboard
#   models, and non-booting external hard drives.
#   Instead of searching for and downloading individual troubleshooting tools on
#   each machine:
#     - 'lspci' / 'lsusb' / 'dmidecode' allow instant identification of internal
#       chips, serial numbers, and BIOS firmware versions from the terminal.
#     - 'smartctl' reads drive health logs and wear indicators, alerting you to
#       impending SSD or hard disk failures before data loss occurs.
#     - 'nwipe' and 'nvme-cli' allow technicians to securely erase district computers
#       prior to surplus or disposal, fulfilling educational privacy requirements.
#     - Filesystem drivers ensure USB drives formatted on Windows or Mac can be
#       read and repaired directly in Linux.
#
# HOW TO USE:
#   - Check drive health: 'sudo smartctl -a /dev/nvme0n1'
#   - Read motherboard serial/tag: 'sudo dmidecode -s system-serial-number'
#   - List all PCIe devices with driver info: 'lspci -nnk'
#   - Inspect CPU temperatures & fans: 'sensors'
#   - Interactive DBAN-style multi-disk wiper: 'sudo nwipe'
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --------------------------------------------------------------------------
    # 1. Hardware Bus, Sensors & Firmware Diagnostics
    # --------------------------------------------------------------------------
    pciutils        # Peripheral Component Interconnect bus query tool (provides 'lspci')
    usbutils        # USB device hierarchy and descriptor inspector (provides 'lsusb')
    dmidecode       # DMI / SMBIOS table reader (reads BIOS version, RAM slots, serials)
    hwinfo          # Comprehensive multi-subsystem hardware reporting tool
    hdparm          # SATA drive diagnostic query and ATA Secure Erase runner
    smartmontools   # Self-Monitoring, Analysis and Reporting Technology ('smartctl')
    lm_sensors      # Hardware monitoring daemon and CLI sensor reader ('sensors')

    # --------------------------------------------------------------------------
    # 2. Storage Partitioning & NIST/DoD Cryptographic Sanitization
    # --------------------------------------------------------------------------
    parted          # GNU command-line disk partition manipulator
    gptfdisk        # Text-mode GUID Partition Table (GPT) editor ('gdisk', 'sgdisk')
    nvme-cli        # Non-Volatile Memory Express CLI ('nvme list', 'nvme format')
    nwipe           # Terminal GUI tool (fork of DBAN) to overwrite drives securely
    scrub           # Writes repetitive patterns over magnetic/flash media to destroy data
    sedutil         # TCG OPAL 2.0 Self-Encrypting Drive (SED) management ('sedutil-cli')

    # --------------------------------------------------------------------------
    # 3. Cross-Platform Filesystem Drivers & Repair Utilities
    # --------------------------------------------------------------------------
    exfatprogs      # User utilities for modern exFAT flash drives (SD cards, USBs)
    ntfs3g          # Read/write FUSE driver and filesystem checker ('ntfsfix') for Windows NTFS
    dosfstools      # Utilities for FAT16 and FAT32 filesystems ('mkfs.vfat', 'fsck.vfat')
    xfsprogs        # Enterprise high-performance journaling XFS filesystem utilities
    btrfs-progs     # Subvolume creation, filesystem balance, and snapshot manipulation
    cifs-utils      # Windows / Samba network share mount helpers ('mount.cifs')
    nfs-utils       # Network File System protocol client and mount utilities
  ];
}
