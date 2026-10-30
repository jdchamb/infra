# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/pelican.nix (Pelican)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Pelican):
#   Deploys the Pelican Panel container ('pelican-panel'), the modern open-source
#   successor to Pterodactyl Panel, used for orchestrating, isolating, and managing
#   containerized game server instances (Minecraft, Palworld, Terraria, etc.)
#   through an intuitive web management dashboard on port 8084.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Running multiple dedicated game servers manually can get messy: each server
#   needs its own ports, files, Java/Node versions, and backup schedules.
#   Pelican provides a unified web control panel where administrators and players
#   can start, stop, monitor CPU/RAM usage, edit config files, and view real-time
#   console logs for any game server running on the machine.
#   - 'virtualisation.docker.enable = true' ensures Docker is running, which Pelican
#     Wings uses to spin up sandboxed game instances.
#   - 'ghcr.io/pelican-dev/panel' runs the web UI and API.
#   - Persistent data is stored in '/var/lib/pelican/'.
#
# HOW TO USE:
#   - Importing this module turns the Pelican Panel container ON immediately.
#   - Web interface: http://<host-ip>:8084
#   - Wings daemon communication port: 8443
#   - First-run setup: Enter the container to create your initial administrator account:
#       docker exec -it pelican-panel php artisan p:user:make
#
# >>> PORT & RUNTIME NOTES <<<
#   - Web UI is mapped to host port 8084 (container port 80).
#   - Port 8443 is opened in the firewall for incoming SSL communication from Wings.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # Docker Daemon
  # Pelican requires the Docker engine to spawn and isolate individual game servers.
  # --------------------------------------------------------------------------
  virtualisation.docker.enable = true;

  # --------------------------------------------------------------------------
  # OCI Container Definition: Pelican Panel Web Dashboard
  # --------------------------------------------------------------------------
  virtualisation.oci-containers.containers."pelican-panel" = {
    # Official container image maintained by the Pelican development team
    image = "ghcr.io/pelican-dev/panel:latest";

    # Port mapping: host 8084 -> container web port 80
    ports = [ "8084:80" ];

    # Persist SQLite/MySQL database, uploads, and server metadata to host disk
    volumes = [
      "/var/lib/pelican/panel:/pelican-data"
    ];

    # Environment settings for the Laravel-based web application
    environment = {
      APP_URL = "http://localhost:8084";
      APP_TIMEZONE = "America/Chicago"; # USD 308 central time zone
    };

    # Automatically start the container when the host boots
    autoStart = true;
  };

  # --------------------------------------------------------------------------
  # Filesystem Directory Creation (systemd-tmpfiles)
  # 'd' rule: creates the directories if missing.
  # Mode 0750: read/write/execute for root, read/execute for root group.
  # --------------------------------------------------------------------------
  systemd.tmpfiles.rules = [
    "d /var/lib/pelican/panel 0750 root root -"
    "d /var/lib/pelican/wings 0750 root root -"
  ];

  # --------------------------------------------------------------------------
  # Firewall Configuration
  # Open web UI (8084) and Wings SSL communication port (8443)
  # --------------------------------------------------------------------------
  networking.firewall.allowedTCPPorts = [ 8084 8443 ];
}
