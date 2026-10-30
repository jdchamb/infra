# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/planka.nix (Kanban Project Board)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Planka):
#   Deploys Planka (self-hosted Kanban project board) via OCI containers on
#   port 3003 for visual tracking of personal and USD 308 infrastructure queues.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Planka is a Trello-style board (columns like To Do / Doing / Done with cards
#   you drag between them). Nixpkgs has no native Planka service, so we run the
#   official container image instead.
#
#   'virtualisation.oci-containers' is NixOS's declarative way to run Docker/
#   Podman containers: NixOS generates a systemd service per container, so it
#   starts at boot and restarts on failure just like a native service.
#
# HOW TO USE:
#   - Importing this module starts the container immediately.
#   - Browse to http://<host-ip>:3003
#   - Planka also needs a PostgreSQL database (DATABASE_URL). This module does
#     not yet provide one, so it is a starting template; add a database
#     before relying on it.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."planka" = {
    # ':latest' always pulls the newest image. Convenient, but upgrades happen
    # silently; pin a version tag (e.g. ':1.24') for predictable behavior.
    image = "ghcr.io/plankanban/planka:latest";
    ports = [ "3003:1337" ];  # host port 3003 -> container's internal port 1337
    volumes = [
      # Persist uploaded avatars on the host so they survive container rebuilds
      "/var/lib/planka:/app/public/user-avatars"
    ];
    environment = {
      BASE_URL = "http://localhost:3003"; # Public URL Planka uses to build links
      TRUST_PROXY = "0";                  # 0 = not behind a reverse proxy
    };
    autoStart = true; # Start automatically at boot
  };

  # Ensure the persistent data directory exists before the container starts
  systemd.tmpfiles.rules = [
    "d /var/lib/planka 0755 root root -"
  ];

  # Allow LAN access to the web UI
  networking.firewall.allowedTCPPorts = [ 3003 ];
}
