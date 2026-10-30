# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/pelican.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Pelican):
#   Deploys the Pelican Panel & Wings game server management plane (the modern
#   open-source successor to Pterodactyl) for orchestrating containerized
#   multiplayer game servers on port 8443/8080.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.docker.enable = true;

  virtualisation.oci-containers.containers."pelican-panel" = {
    image = "ghcr.io/pelican-dev/panel:latest";
    ports = [ "8084:80" ];
    volumes = [
      "/var/lib/pelican/panel:/pelican-data"
    ];
    environment = {
      APP_URL = "http://localhost:8084";
      APP_TIMEZONE = "America/Chicago";
    };
    autoStart = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/pelican/panel 0750 root root -"
    "d /var/lib/pelican/wings 0750 root root -"
  ];

  networking.firewall.allowedTCPPorts = [ 8084 8443 ];
}
