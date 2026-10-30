# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/terraria.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Terraria):
#   Deploys a dedicated Terraria server ('services.terraria') on port 7777.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Nixpkgs ships a native Terraria server module, so (unlike Palworld) no
#   container is needed. NixOS creates the service user, runs the server under
#   systemd, and auto-generates a world file on first launch.
#
# HOW TO USE:
#   - Importing this module starts the server immediately.
#   - Players use "Join via IP" with <host-ip> and port 7777.
#   - To attach to the live server console: 'sudo -u terraria terraria-server-attach'
#     (name may vary by nixpkgs version; see 'systemctl status terraria').
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.terraria = {
    enable = true;
    openFirewall = true;  # Open TCP 7777 in the NixOS firewall
    port = 7777;          # Default Terraria port
    maxPlayers = 8;
    # Path to the world file. If it doesn't exist, it will be created using
    # 'autoCreateWorldSize' below.
    worldPath = "/var/lib/terraria/HomelabWorld.wld";
    autoCreateWorldSize = "medium"; # small | medium | large
  };
}
