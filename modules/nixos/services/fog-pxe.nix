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
#     - 'partclone', 'ipxe', and 'pigz' imaging utilities
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When imaging computer labs or provisioning bare-metal workstations, walking
#   around with USB sticks is slow. PXE (Preboot Execution Environment) allows
#   a computer to boot directly over the Ethernet cable from the network.
#   The target machine downloads a bootloader via TFTP (port 69) and mounts
#   disk image archives over NFS (port 2049) to clone operating systems rapidly.
#
# HOW TO USE:
#   - Importing this module turns the NFS and TFTP servers ON immediately.
#   - Place iPXE bootloader binaries (undionly.kpxe, ipxe.efi) into '/srv/tftp'.
#   - Configure your network DHCP server (Option 66/67) to point next-server to
#     this machine's IP and boot filename to 'undionly.kpxe' or 'ipxe.efi'.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # Ensure storage directories for disk images and TFTP files exist with correct permissions
  systemd.tmpfiles.rules = [
    "d /srv/fog-images 0775 root wheel -"
    "d /srv/fog-images/dev 0775 root wheel -"
    "d /srv/tftp 0755 root root -"
  ];

  # Network File System (NFS) export configuration for streaming disk images to PXE clients
  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/fog-images     *(ro,sync,no_wdelay,no_subtree_check,insecure_locks,no_root_squash,insecure)
      /srv/fog-images/dev *(rw,async,no_wdelay,no_subtree_check,no_root_squash,insecure)
    '';
  };

  # Trivial File Transfer Protocol (TFTP) service for delivering initial pre-boot binaries
  services.atftpd = {
    enable = true;
    root = "/srv/tftp"; # Root folder served over TFTP port 69
  };

  # CLI utilities for handling disk partitioning, raw block cloning, and gzip compression
  environment.systemPackages = with pkgs; [
    ipxe      # Open-source network boot firmware
    partclone # Block-level partition backup and restore utility
    pigz      # Parallel multi-threaded gzip compressor
  ];

  # Firewall rules: open RPC (111), NFS (2049), TFTP (69), and HTTP staging (8080)
  networking.firewall = {
    allowedTCPPorts = [ 111 2049 8080 ];
    allowedUDPPorts = [ 69 111 2049 ];
  };
}
