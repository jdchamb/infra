# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/memos.nix (Memos Notes Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 3 — 1-to-1 Module for Memos):
#   Deploys Memos ('services.memos'), a privacy-first, lightweight self-hosted
#   note-taking and daily engineering log service on port 5230.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.memos = {
    enable = true;
    port = 5230;
    openFirewall = true;
  };
}
