# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/vlc.nix (VLC Multimedia & RTSP Player)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 1 & Personal Project 16 — 1-to-1 Module for VLC):
#   Installs the VLC media player for desktop video playback and live RTSP/ONVIF
#   stream inspection (such as testing PoE Reolink doorbell camera feeds).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   VLC plays almost any audio/video format without extra codecs. More
#   importantly for infrastructure work, it can open network camera streams:
#     Media -> Open Network Stream -> rtsp://<camera-ip>:554/h264Preview_01_main
#   That lets you confirm a newly installed PoE camera is streaming correctly
#   before adding it to Home Assistant. It also mirrors the VLC package that
#   USD 308 deploys to Windows PCs via PDQ (308 Project 1).
# ==============================================================================

{ pkgs, ... }:

{
  # Install VLC media player
  environment.systemPackages = [
    pkgs.vlc
  ];
}
