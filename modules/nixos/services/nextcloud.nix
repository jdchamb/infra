# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/nextcloud.nix (Nextcloud Suite)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 3 — 1-to-1 Module):
#   Deploys Nextcloud ('services.nextcloud') with PostgreSQL and Redis caching
#   for self-hosted file synchronization, CalDAV calendars, and CardDAV contacts.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud30;
    hostName = "cloud.homelab.local";
    database.createLocally = true;
    configureRedis = true;
    maxUploadSize = "16G";

    config = {
      dbtype = "pgsql";
      adminuser = "jchambers";
      adminpassFile = "/etc/nixos/secrets/nextcloud-admin-pass";
    };
  };

  systemd.tmpfiles.rules = [
    "f /etc/nixos/secrets/nextcloud-admin-pass 0600 nextcloud nextcloud - changeme-nextcloud"
  ];
}
