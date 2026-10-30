# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/nextcloud.nix (Nextcloud Suite)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 3 — 1-to-1 Module):
#   Deploys Nextcloud ('services.nextcloud') with PostgreSQL and Redis caching
#   for self-hosted file synchronization, CalDAV calendars, and CardDAV contacts.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Nextcloud is a self-hosted replacement for Google Drive + Google Calendar +
#   Contacts. The NixOS module wires up all the moving parts for you:
#     - nginx web server (serves the PHP app on port 80 by default)
#     - PHP-FPM (runs Nextcloud's PHP code)
#     - PostgreSQL ('database.createLocally') to store metadata
#     - Redis ('configureRedis') for caching and file-locking, which makes the
#       web UI noticeably faster and prevents sync conflicts.
#
# HOW TO USE:
#   - Importing this module turns Nextcloud ON immediately.
#   - 'hostName' must match the name you type in the browser. Add
#     'cloud.homelab.local' to your DNS (AdGuard/Pi-hole) or /etc/hosts,
#     then browse to http://cloud.homelab.local
#   - Note: this module does NOT open firewall port 80 by itself; the host
#     (or a reverse-proxy module) must allow it for LAN access.
#
# >>> SECURITY WARNING (READ BEFORE DEPLOYING) <<<
#   The admin password is seeded as the placeholder 'changeme-nextcloud' via
#   the tmpfiles rule below. It is visible in this repo and in /nix/store.
#   Change it after first login, or replace the rule with a sops-nix secret.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.nextcloud = {
    enable = true;
    # Pinned major version. Nextcloud only supports upgrading ONE major version
    # at a time (30 -> 31 -> 32), so bump this number deliberately, never skip.
    package = pkgs.nextcloud30;
    hostName = "cloud.homelab.local"; # Virtual host name nginx answers to
    database.createLocally = true;     # Auto-create a local PostgreSQL DB + user
    configureRedis = true;             # Auto-configure Redis cache & file locking
    maxUploadSize = "16G";             # Allow large uploads (ISOs, videos)

    config = {
      dbtype = "pgsql";                                    # Use PostgreSQL (not SQLite)
      adminuser = "jchambers";                             # Initial admin username
      adminpassFile = "/etc/nixos/secrets/nextcloud-admin-pass"; # Initial admin password file
    };
  };

  # Seed the admin password file only if it doesn't exist yet (see WARNING above)
  systemd.tmpfiles.rules = [
    "f /etc/nixos/secrets/nextcloud-admin-pass 0600 nextcloud nextcloud - changeme-nextcloud"
  ];
}
