# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/printing.nix (CUPS & Avahi mDNS Discovery)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Enables the Common UNIX Printing System (CUPS) daemon and Avahi zero-config
#   mDNS hostname resolution (.local), allowing workstations to automatically
#   discover and print to networked office and label printers.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Enable the CUPS printing spooler daemon
  services.printing.enable = true;

  # 2. Enable Avahi mDNS/DNS-SD for automatic network printer & host discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
