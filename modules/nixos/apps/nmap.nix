# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/nmap.nix (Network Discovery & Port Scanner)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 16 & 17 — 1-to-1 Module for Nmap):
#   Installs 'nmap' for subnet host discovery, switch management port auditing,
#   and RTSP/ONVIF service probing on Reolink PoE doorbell cameras.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When you plug a new device (camera, switch, ClearTouch board) into the
#   network, you often don't know what IP address it received. 'nmap' scans a
#   range of addresses and reports which hosts are alive and which "ports"
#   (services like SSH=22, HTTP=80, RTSP=554) they have open.
#
# QUICK USAGE:
#   nmap -sn 192.168.1.0/24          # Ping-sweep: list every live host on the subnet
#   nmap -p 22,80,443,554 <ip>       # Check specific service ports on one device
#
# NOTE: Only scan networks you own or are authorized to administer.
# ==============================================================================

{ pkgs, ... }:

{
  # Install the nmap network scanner
  environment.systemPackages = [
    pkgs.nmap
  ];
}
