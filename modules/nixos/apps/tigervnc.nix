# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/tigervnc.nix (TigerVNC Remote Viewer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 10 — 1-to-1 Module for TigerVNC):
#   Installs TigerVNC ('vncviewer') for high-performance, low-latency VNC
#   sessions to UltraVNC-managed Windows 11 fleet devices.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   VNC (Virtual Network Computing) streams a remote computer's screen to you.
#   TigerVNC's 'vncviewer' is a small, fast, dependency-light viewer that works
#   on any desktop and is easy to call from scripts:
#     vncviewer 10.14.20.45
#   It is the same viewer installed on the MacBooks via Homebrew ('tigervnc'
#   cask), so the experience is identical across the fleet.
# ==============================================================================

{ pkgs, ... }:

{
  # Install TigerVNC client ('vncviewer')
  environment.systemPackages = [
    pkgs.tigervnc
  ];
}
