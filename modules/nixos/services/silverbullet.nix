# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/silverbullet.nix (Technical Wiki)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 8 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys SilverBullet ('services.silverbullet'), an extensible, local-first
#   Markdown technical wiki and knowledge base on port 3002 for USD 308
#   Technology Department documentation and homelab runbooks.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.silverbullet = {
    enable = true;
    spaceDir = "/var/lib/silverbullet";
    listenPort = 3002;
    listenAddress = "0.0.0.0";
    openFirewall = true;
  };
}
