{ config, pkgs, ... }:

{
  # Use the latest Linux kernel (Great for your HP hardware and GPU support)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Allow the kernel to pass commands to self-encrypting drive controllers (Required for sedutil-cli)
  boot.kernelParams = [ "libata.allow_tpm=1" ];

  # Bootloader settings
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Clean up the boot screen a bit
  boot.loader.timeout = 5;
}
