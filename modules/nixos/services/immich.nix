# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/immich.nix (Immich Photo Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Immich):
#   Deploys Immich ('services.immich'), a high-performance self-hosted photo and
#   video backup server with machine-learning facial recognition and semantic
#   CLIP search on port 2283.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
    mediaLocation = "/var/lib/immich/media";
  };
}
