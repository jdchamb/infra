# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/printing.nix (CUPS & Avahi mDNS Discovery)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Enables the Common UNIX Printing System (CUPS) daemon and Avahi zero-config
#   mDNS hostname resolution (.local), allowing workstations to automatically
#   discover and print to networked office and USB label printers.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Linux uses two separate services to make "plug-and-play" printing work like
#   macOS or Windows:
#     1. 'CUPS' (services.printing): The print spooler that converts PDFs/labels
#        into printer-specific page descriptions (PostScript, PCL, or Dymo raster).
#     2. 'Avahi' (services.avahi): Linux's implementation of Apple Bonjour / mDNS.
#        It listens on UDP port 5353 so printers on the local LAN (and '.local'
#        hostnames) appear automatically without typing raw IP addresses.
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Enable the CUPS printing spooler daemon (accessible locally at http://localhost:631)
  services.printing.enable = true;

  # 2. Enable Avahi mDNS/DNS-SD for automatic network printer & '.local' host discovery
  services.avahi = {
    enable = true;
    # Hook mDNS into the system Name Service Switch (NSS) so 'ping host.local' works
    nssmdns4 = true;
    # Open UDP port 5353 in the local firewall for multicast DNS discovery packets
    openFirewall = true;
  };
}
