# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/memos.nix (Memos Notes Server)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 3 — 1-to-1 Module for Memos):
#   Deploys Memos ('services.memos'), a privacy-first, lightweight self-hosted
#   note-taking and daily engineering log service on port 5230.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Memos is like a private Twitter/sticky-note feed: quick timestamped notes,
#   checklists, and snippets you can jot from any browser or phone. It is far
#   lighter than a full wiki (see 'silverbullet.nix' for structured docs), which
#   makes it ideal for an engineering journal ("what did I change today?").
#
# HOW TO USE:
#   - Importing this module into a host turns Memos ON immediately.
#   - Browse to http://<host-ip>:5230 and create the first (admin) account.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.memos = {
    enable = true;
    port = 5230;         # Web UI / API port
    openFirewall = true; # Allow LAN devices to reach port 5230
  };
}
