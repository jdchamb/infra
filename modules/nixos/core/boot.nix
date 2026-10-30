# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/boot.nix (Kernel & UEFI Bootloader)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the core Linux kernel package set ('linuxPackages_latest'),
#   enables hardware self-encrypting drive communication flags ('libata.allow_tpm=1'),
#   and sets up the modern UEFI 'systemd-boot' loader menu with a 5-second timeout.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When your computer turns on, motherboard UEFI firmware hands execution over
#   to a bootloader, which loads the Linux kernel into memory:
#   - 'systemd-boot': A minimal, fast UEFI bootloader tailored for modern hardware.
#     Unlike legacy GRUB, it requires no complex runtime scripting; NixOS generates
#     clean bootloader entry files automatically for every generation you build.
#   - Generational Rollbacks: Every time you run 'nixos-rebuild switch', NixOS adds
#     a new entry to the systemd-boot menu. If an update ever prevents your system
#     from starting, reboot, pick the previous generation from the 5-second menu,
#     and the system boots into the known-good state.
#   - 'canTouchEfiVariables': Grants permission for NixOS activation scripts to write
#     to the motherboard's non-volatile NVRAM boot order so your machine defaults
#     to booting NixOS.
#   - 'linuxPackages_latest': Pulls the newest mainline stable Linux kernel release.
#     This ensures the latest hardware drivers, power management patches, and Wi-Fi
#     firmware are available for modern laptops (like HP ProBook) and desktops.
#   - 'libata.allow_tpm=1': TCG OPAL self-encrypting drives (SEDs) use hardware-level
#     encryption on the SSD controller. Linux ATA drivers block Opal security commands
#     by default; this parameter allows the 'sedutil-cli' utility to communicate with
#     the drive controller to unlock or query hardware encryption status.
#
# HOW TO USE:
#   - Applied automatically to all NixOS hosts importing this core module.
#   - Access the bootloader menu: Turn on the computer; when the systemd-boot menu
#     appears, press arrow keys within 5 seconds to select an older generation.
#   - Check current running kernel version: 'uname -r'
# ==============================================================================

{ config, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Linux Kernel Selection
  # Tracks the newest stable mainline Linux kernel from Nixpkgs for up-to-date
  # hardware support, Intel CPU schedulers, and wireless chipset drivers.
  # --------------------------------------------------------------------------
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # --------------------------------------------------------------------------
  # 2. Kernel Command-Line Parameters
  # Allow the Linux ATA driver subsystem to pass TCG OPAL security commands
  # through to self-encrypting SATA/NVMe storage controllers (needed for sedutil-cli).
  # --------------------------------------------------------------------------
  boot.kernelParams = [ "libata.allow_tpm=1" ];

  # --------------------------------------------------------------------------
  # 3. UEFI Bootloader (systemd-boot)
  # --------------------------------------------------------------------------
  # Enable the UEFI systemd-boot bootloader (formerly known as Gummiboot)
  boot.loader.systemd-boot.enable = true;

  # Allow the installer and rebuild tools to update motherboard UEFI boot variables
  boot.loader.efi.canTouchEfiVariables = true;

  # --------------------------------------------------------------------------
  # 4. Boot Menu Timeout
  # Display the boot generation selection menu for 5 seconds before booting default
  # --------------------------------------------------------------------------
  boot.loader.timeout = 5;
}
