# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/tigervnc.nix (TigerVNC Remote Viewer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 10 — 1-to-1 Module for TigerVNC):
#   Installs TigerVNC ('vncviewer') for high-performance, low-latency VNC
#   sessions to UltraVNC-managed Windows 11 fleet devices.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.tigervnc
  ];
}
