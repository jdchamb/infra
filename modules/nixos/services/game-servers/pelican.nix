# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/pelican.nix (Pelican)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — Pelican Panel):
#   Deploys Pelican Panel ('ghcr.io/pelican-dev/panel') on port 8084.
#   Pelican is the modern open-source successor to Pterodactyl Panel, providing
#   an interactive web management dashboard with real-time in-game console
#   execution, player management, and CPU/RAM graphs.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   While OliveTin provides simple 1-click on/off buttons for your son, Pelican
#   is a full gaming administration panel. It gives server operators a web-based
#   terminal to run in-game commands (e.g. '/gamemode creative', '/op player',
#   '/time set day') without needing SSH terminal access.
#
# HOW TO USE:
#   - Enable via:
#       services.fleet.game-servers.gui.pelican.enable = true;
#   - Web interface: http://<host-ip>:8084
#   - Wings daemon communication port: 8443
#   - First-run setup: Enter the container to create your initial administrator account:
#       podman exec -it pelican-panel php artisan p:user:make
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.gui.pelican;
in
{
  options.services.fleet.game-servers.gui.pelican = {
    enable = lib.mkEnableOption "Pelican Game Server Management Panel & Wings";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8084;
      description = "Host web dashboard port for Pelican Panel.";
    };

    wingsPort = lib.mkOption {
      type = lib.types.port;
      default = 8443;
      description = "SSL port for Wings daemon communication.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${parentCfg.stateDir}/pelican";
      description = "Host directory where Pelican panel and wings data persist.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open web and Wings ports in the NixOS firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # --------------------------------------------------------------------------
    # OCI Container Definition: Pelican Panel Web Dashboard
    # --------------------------------------------------------------------------
    virtualisation.oci-containers.containers."pelican-panel" = {
      image = "ghcr.io/pelican-dev/panel:latest";
      ports = [ "${toString cfg.port}:80" ];

      volumes = [
        "${cfg.dataDir}/panel:/pelican-data"
      ];

      environment = {
        APP_URL = "http://localhost:${toString cfg.port}";
        APP_TIMEZONE = config.time.timeZone or "America/Chicago";
      };

      autoStart = true;
    };

    # Directory creation for Panel and Wings state
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}/panel 0750 root root -"
      "d ${cfg.dataDir}/wings 0750 root root -"
    ];

    # Open web UI and Wings ports in firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port cfg.wingsPort ];
  };
}
