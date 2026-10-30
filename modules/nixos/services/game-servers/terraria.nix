# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/terraria.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Terraria):
#   Deploys a dedicated Terraria server ('services.terraria') on port 7777.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.terraria = {
    enable = true;
    openFirewall = true;
    port = 7777;
    maxPlayers = 8;
    worldPath = "/var/lib/terraria/HomelabWorld.wld";
    autoCreateWorldSize = "medium";
  };
}
