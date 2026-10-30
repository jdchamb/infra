# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/forgejo.nix (Self-Hosted Git Forge)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 24 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys a self-hosted Forgejo Git forge (the open-source engine powering
#   Codeberg.org) on port 3001. Can act as an internal USD 308 / homelab Git
#   server and automatic pull-mirror for Codeberg repositories.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "git.homelab.local";
        HTTP_PORT = 3001;
        ROOT_URL = "http://git.homelab.local:3001/";
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
      actions = {
        ENABLED = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3001 ];
}
