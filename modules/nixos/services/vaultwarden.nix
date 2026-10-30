# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/vaultwarden.nix (Password Vault)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys a self-hosted, Bitwarden-compatible enterprise password manager
#   vault ('services.vaultwarden') for the USD 308 Technology Department and
#   personal homelab. Supports shared organizational collections, WebSockets,
#   and automated SQLite backups in '/var/backup/vaultwarden'.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    dbBackend = "sqlite";
    backupDir = "/var/backup/vaultwarden";

    config = {
      DOMAIN = "https://vault.usd308.local";
      SIGNUPS_ALLOWED = false;
      INVITATIONS_ALLOWED = true;
      ORG_CREATION_USERS = "all";
      WEBSOCKET_ENABLED = true;
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;
      EXTENDED_LOGGING = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/backup/vaultwarden 0700 vaultwarden vaultwarden -"
  ];

  networking.firewall.allowedTCPPorts = [ 8222 ];
}
