# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/barotrauma.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Sandboxed Barotrauma Dedicated Server):
#   Deploys an isolated Barotrauma dedicated multiplayer submarine server via Podman.
#   Configured for:
#     - Pure FOSS container runtime (Podman sandbox)
#     - Game traffic on UDP 27015, Steam query on UDP 27016
#     - Persistent state in '/var/lib/game-servers/barotrauma' (campaign saves,
#       custom submarines, server settings)
#     - On-demand control ('autoStart = false') so your son can start it via OliveTin
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Barotrauma dedicated servers are distributed through SteamCMD. Running inside
#   a container isolates all server dependencies from NixOS while mapping the
#   '/persistence' volume directly to the host disk, ensuring your submarine designs
#   and crew campaigns are never wiped during system rebuilds.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.barotrauma;
in
{
  options.services.fleet.game-servers.barotrauma = {
    enable = lib.mkEnableOption "Sandboxed Barotrauma dedicated server";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to start the server automatically on system boot.
        Leave false for on-demand activation via OliveTin or game-ctl.
      '';
    };

    gamePort = lib.mkOption {
      type = lib.types.port;
      default = 27015;
      description = "Game traffic UDP port for Barotrauma.";
    };

    queryPort = lib.mkOption {
      type = lib.types.port;
      default = 27016;
      description = "Steam server query UDP port.";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Homelab Sandboxed Barotrauma";
      description = "Server title displayed in the server browser.";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional password required for crew members to join.";
    };

    public = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Publish server publicly to the master server list (false keeps it private/LAN).";
    };

    language = lib.mkOption {
      type = lib.types.str;
      default = "English";
      description = "Server language.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${parentCfg.stateDir}/barotrauma";
      description = "Host directory where submarine saves, campaigns, and configs persist.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open required UDP ports in the host firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # --------------------------------------------------------------------------
    # OCI Container Definition (Podman)
    # --------------------------------------------------------------------------
    virtualisation.oci-containers.containers."barotrauma-server" = {
      image = "docker.io/yanwk/barotrauma-server:dockerful";
      autoStart = cfg.autoStart;

      ports = [
        "${toString cfg.gamePort}:27015/udp"
        "${toString cfg.queryPort}:27016/udp"
      ];

      volumes = [
        "${cfg.dataDir}:/persistence"
      ];

      environment = {
        DEFAULT_SERVERNAME = cfg.serverName;
        DEFAULT_PASSWORD = if cfg.password != null then cfg.password else "";
        DEFAULT_PUBLICITY = if cfg.public then "true" else "false";
        DEFAULT_LANGUAGE = cfg.language;
      };

      extraOptions = [
        "--security-opt=no-new-privileges:true"
      ];
    };

    # Ensure host save directory exists with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0777 root root -"
    ];

    # Open UDP ports in firewall
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ cfg.gamePort cfg.queryPort ];
  };
}
