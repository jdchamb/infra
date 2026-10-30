# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/scrcpy.nix (Android Screen Mirroring)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 27 — 1-to-1 Module for Scrcpy):
#   Installs 'scrcpy' for low-latency, hardware-accelerated remote screen viewing
#   and touch/keyboard control of Android devices and ClearTouch interactive boards.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   ClearTouch classroom boards run Android. 'scrcpy' ("screen copy") opens a
#   window on your Linux desktop that mirrors the board's screen and lets you
#   click/type on it with your mouse and keyboard—no app needs to be installed
#   on the board. It rides on top of ADB ('adb.nix'), so connect first with
#   'adb connect <board-ip>:5555', then run 'scrcpy -s <board-ip>:5555'.
# ==============================================================================

{ pkgs, ... }:

{
  # Install scrcpy Android screen mirroring & remote control tool
  environment.systemPackages = [
    pkgs.scrcpy
  ];
}
