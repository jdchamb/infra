# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/scrcpy.nix (Android Screen Mirroring)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 27 — 1-to-1 Module for Scrcpy):
#   Installs 'scrcpy' for low-latency, hardware-accelerated remote screen viewing
#   and touch/keyboard control of Android devices and ClearTouch interactive boards.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.scrcpy
  ];
}
