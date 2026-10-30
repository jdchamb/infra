# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/cockpit.nix (Web System Admin)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Cockpit):
#   Enables Cockpit ('services.cockpit') on port 9090 for web-based graphical
#   inspection of systemd units, journal logs, storage mounts, and network
#   interfaces across headless lab and server nodes.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Cockpit is a lightweight web GUI for Linux servers. It lets you monitor
#   CPU/RAM load, review systemd service failures, read journal logs, manage
#   storage disks, and even access a web terminal from any web browser without
#   requiring desktop environments like GNOME or KDE.
#
# HOW TO USE:
#   - Importing this module turns Cockpit ON immediately.
#   - Web interface: https://<host-ip>:9090
#   - Log in using your standard Linux user account credentials (e.g. 'jchambers').
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.cockpit = {
    enable = true;
    port = 9090;         # Cockpit HTTPS web port
    openFirewall = true; # Open port 9090 in the NixOS firewall
  };
}
