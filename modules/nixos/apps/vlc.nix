# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/vlc.nix (VLC Multimedia & RTSP Player)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 1 & Personal Project 16 — 1-to-1 Module for VLC):
#   Installs the VLC media player for desktop video playback and live RTSP/ONVIF
#   stream inspection (such as testing PoE Reolink doorbell camera feeds).
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.vlc
  ];
}
