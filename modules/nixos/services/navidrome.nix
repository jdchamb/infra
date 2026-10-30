# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/navidrome.nix (Music Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Navidrome):
#   Deploys Navidrome ('services.navidrome'), a lightweight Subsonic-compatible
#   self-hosted music streaming server on port 4533.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/var/lib/navidrome/music";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/navidrome/music 0755 navidrome navidrome -"
  ];
}
