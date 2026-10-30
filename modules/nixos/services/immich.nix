# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/immich.nix (Immich Photo Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Immich):
#   Deploys Immich ('services.immich'), a high-performance self-hosted photo and
#   video backup server with machine-learning facial recognition and semantic
#   CLIP search on port 2283.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Immich is an open-source, self-hosted replacement for Google Photos or Apple
#   iCloud Photos. It backs up mobile photos automatically from iOS/Android
#   apps, performs face recognition and object detection locally using ML
#   models, and displays an interactive map of where your photos were taken.
#
# HOW TO USE:
#   - Importing this module turns Immich ON immediately.
#   - Web interface: http://<host-ip>:2283
#   - First-time setup: browse to the URL and register the root admin user.
#   - Mobile Apps: install the official Immich app on iOS or Android, enter
#     your server URL, and enable background camera roll backup.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0"; # Listen on all network interfaces for LAN / mobile sync
    port = 2283;       # Default Immich web & API port
    openFirewall = true; # Open TCP port 2283 in the NixOS firewall
    # Persistent directory where raw photo/video libraries and thumbnails reside
    mediaLocation = "/var/lib/immich/media";
  };
}
