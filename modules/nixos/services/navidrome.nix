# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/navidrome.nix (Music Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Navidrome):
#   Deploys Navidrome ('services.navidrome'), a lightweight Subsonic-compatible
#   self-hosted music streaming server on port 4533.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Navidrome turns a folder of music files into your own Spotify-style
#   streaming service. Because it speaks the "Subsonic" API, dozens of existing
#   phone and desktop music apps can connect to it. It uses very little RAM,
#   so it can run alongside other services on modest hardware.
#
# HOW TO USE:
#   - Importing this module turns Navidrome ON immediately.
#   - Copy music into /var/lib/navidrome/music (or change MusicFolder below).
#   - Browse to http://<host-ip>:4533 and create the admin account.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true; # Open the configured Port in the NixOS firewall
    settings = {
      # 0.0.0.0 = listen on ALL network interfaces (LAN-accessible).
      # Change to "127.0.0.1" if you only want access through a reverse proxy.
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/var/lib/navidrome/music"; # Where Navidrome scans for audio files
    };
  };

  # systemd-tmpfiles creates directories at boot if they don't exist.
  # Format: "d <path> <mode> <owner> <group> <age>"
  # This guarantees the music folder exists and is owned by the service user.
  systemd.tmpfiles.rules = [
    "d /var/lib/navidrome/music 0755 navidrome navidrome -"
  ];
}
