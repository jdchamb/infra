# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/fog-pxe.nix (FOG / PXE Imaging)
# ==============================================================================
#
# ROLE & ARCHITECTURE (USD 308 Project 15 — 1-to-1 Module for FOG PXE Server):
#   Provides a modern Linux-backed PXE/iPXE network boot and disk imaging server
#   to replace deprecated Microsoft Windows Deployment Services (WDS):
#     - TFTP server ('atftpd') serving iPXE firmware binaries ('/srv/tftp')
#     - Kernel NFSv4 server exporting '/srv/fog-images' for high-speed multicast
#       and unicast Windows 11 & Linux bare-metal imaging
#     - 'partclone' & 'ipxe' imaging utilities
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  systemd.tmpfiles.rules = [
    "d /srv/fog-images 0775 root wheel -"
    "d /srv/fog-images/dev 0775 root wheel -"
    "d /srv/tftp 0755 root root -"
  ];

  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/fog-images     *(ro,sync,no_wdelay,no_subtree_check,insecure_locks,no_root_squash,insecure)
      /srv/fog-images/dev *(rw,async,no_wdelay,no_subtree_check,no_root_squash,insecure)
    '';
  };

  services.atftpd = {
    enable = true;
    root = "/srv/tftp";
  };

  environment.systemPackages = with pkgs; [
    ipxe
    partclone
    pigz
  ];

  networking.firewall = {
    allowedTCPPorts = [ 111 2049 8080 ];
    allowedUDPPorts = [ 69 111 2049 ];
  };
}
