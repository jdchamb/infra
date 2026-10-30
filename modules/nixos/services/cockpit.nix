# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/cockpit.nix (Web System Admin)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Cockpit):
#   Enables Cockpit ('services.cockpit') on port 9090 for web-based graphical
#   inspection of systemd units, journal logs, storage mounts, and network
#   interfaces across headless lab and server nodes.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = true;
  };
}
