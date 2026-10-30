# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/boot.nix (Kernel & UEFI Bootloader)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the mainline Linux kernel stream ('linuxPackages_latest'),
#   TCG OPAL self-encrypting drive kernel flags ('libata.allow_tpm=1'), and
#   the UEFI 'systemd-boot' bootloader handoff behavior.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Track the mainline latest stable Linux kernel for optimal Intel/HP/GPU support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 2. Allow the kernel to pass Opal security commands to self-encrypting SATA/NVMe
  #    drive controllers (Required for 'sedutil-cli' hardware encryption diagnostics)
  boot.kernelParams = [ "libata.allow_tpm=1" ];

  # 3. UEFI Bootloader Handoff Configuration (systemd-boot)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 4. Limit generation menu selection timeout to 5 seconds for fast reboots
  boot.loader.timeout = 5;
}
