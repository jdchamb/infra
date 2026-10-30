# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/jellyfin.nix (Jellyfin Media Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Jellyfin):
#   Deploys Jellyfin ('services.jellyfin') with VA-API / Intel QuickSync hardware
#   video transcoding acceleration enabled on port 8096.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Jellyfin is a free, self-hosted "Netflix for your own files": it organizes
#   movies/TV/home videos and streams them to browsers, TVs, and phones.
#   When a device can't play a file's format directly, Jellyfin "transcodes"
#   (converts it on the fly). Doing that on the CPU is slow and hot; doing it on
#   the Intel GPU (QuickSync/VA-API) is fast and efficient.
#
# HOW TO USE:
#   - Importing this module into a host turns Jellyfin ON immediately.
#   - Open http://<host-ip>:8096 to run the first-time setup wizard.
#   - In Dashboard -> Playback, choose "Intel QuickSync" or "VA-API" acceleration.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    # Opens TCP 8096 (HTTP) and the discovery ports in the NixOS firewall so
    # other devices on the LAN can reach the server.
    openFirewall = true;
  };

  # The Jellyfin service runs as its own unprivileged 'jellyfin' user.
  # GPU devices (/dev/dri/renderD128) are owned by the 'video' and 'render'
  # groups, so the service user must join them to use hardware transcoding.
  users.users.jellyfin.extraGroups = [ "video" "render" ];
}
