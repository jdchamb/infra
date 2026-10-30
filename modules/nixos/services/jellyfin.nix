# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/jellyfin.nix (Jellyfin Media Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Jellyfin):
#   Deploys Jellyfin ('services.jellyfin') with VA-API / Intel QuickSync hardware
#   video transcoding acceleration enabled on port 8096.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  users.users.jellyfin.extraGroups = [ "video" "render" ];
}
