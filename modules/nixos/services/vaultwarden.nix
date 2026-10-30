# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/vaultwarden.nix (Password Vault)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys Vaultwarden ('services.vaultwarden'), a lightweight, self-hosted
#   password vault server written in Rust that is 100% compatible with the official
#   Bitwarden browser extensions, desktop apps, and mobile applications.
#   Configured for USD 308 Technology Department and homelab credential management
#   with automated SQLite database backups on port 8222.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Managing passwords securely is critical. Cloud-hosted password managers can
#   experience outages or security breaches. Vaultwarden allows USD 308 and your
#   homelab to store passwords, notes, and two-factor authentication tokens on
#   your own server. It uses the SQLite database engine for near-zero memory usage
#   and includes built-in WebSocket support for instant password syncing across
#   devices.
#
# HOW TO USE:
#   - Importing this module turns Vaultwarden ON immediately.
#   - Service listens on: http://<host-ip>:8222
#   - IMPORTANT: Bitwarden browser extensions and mobile apps REQUIRE HTTPS
#     (encrypted connections) to log in or sync, unless accessing via 'localhost'.
#     For remote access, place Vaultwarden behind a reverse proxy (e.g. Caddy,
#     Nginx, or Traefik) configured with a valid SSL/TLS certificate.
#   - Automated SQLite snapshots are saved in: /var/backup/vaultwarden
#   - Signups are closed by default ('SIGNUPS_ALLOWED = false') for security;
#     administrators send invitations to new users.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # Vaultwarden Service Configuration
  # --------------------------------------------------------------------------
  services.vaultwarden = {
    # Importing this module turns the Vaultwarden systemd service ON immediately
    enable = true;

    # Use SQLite backend (low CPU and RAM overhead; ideal for single-server fleets)
    dbBackend = "sqlite";

    # Directory where periodic automated SQLite database dumps are saved
    backupDir = "/var/backup/vaultwarden";

    # Runtime environment settings for the Vaultwarden daemon
    config = {
      # The canonical URL clients use to connect. Set to your domain or reverse proxy.
      DOMAIN = "https://vault.usd308.local";

      # Disable open public registration to prevent unauthorized users from creating accounts
      SIGNUPS_ALLOWED = false;

      # Allow existing administrators/members to invite new users via email
      INVITATIONS_ALLOWED = true;

      # Allow all users to create shared organizational collections (team vaults)
      ORG_CREATION_USERS = "all";

      # Enable WebSocket notifications so client devices sync changes in real time
      WEBSOCKET_ENABLED = true;

      # Rocket web server IP binding: "0.0.0.0" listens on all local network adapters
      ROCKET_ADDRESS = "0.0.0.0";

      # Rocket web server listening port
      ROCKET_PORT = 8222;

      # Enable verbose timestamped logs to assist with troubleshooting connection issues
      EXTENDED_LOGGING = true;
    };
  };

  # --------------------------------------------------------------------------
  # Filesystem Permissions (systemd-tmpfiles)
  # 'd' rule: creates the backup directory if missing.
  # Mode 0700: only the 'vaultwarden' system user and root can read or write backups.
  # --------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d /var/backup/vaultwarden 0700 vaultwarden vaultwarden -"
  ];

  # --------------------------------------------------------------------------
  # Firewall Configuration
  # Open port 8222 in the Linux iptables/nftables firewall so clients on the
  # local network or reverse proxies can communicate with Vaultwarden.
  # --------------------------------------------------------------------------
  networking.firewall.allowedTCPPorts = [ 8222 ];
}
