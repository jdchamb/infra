# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/palworld.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Sandboxed Palworld Dedicated Server):
#   Deploys an isolated Palworld dedicated multiplayer server via Podman.
#   Configured for:
#     - Pure FOSS container runtime (Podman sandbox)
#     - Game traffic on UDP 8211, Steam query on UDP 27015
#     - Persistent state in '/var/lib/game-servers/palworld'
#     - Multi-threading enabled for Intel multi-core performance
#     - On-demand control ('autoStart = false') so your son can start it via OliveTin
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   The Palworld server relies on SteamCMD to pull binary updates directly from
#   Steam. Running it inside a container isolates SteamCMD completely from the
#   NixOS root system while keeping all Pal saves, world maps, and guild bases
#   safely persisted on the host disk.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.palworld;
in
{
  options.services.fleet.game-servers.palworld = {
    enable = lib.mkEnableOption "Sandboxed Palworld dedicated server";

    autoStart = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to start the server automatically on system boot.
        Leave false for on-demand activation via OliveTin or game-ctl.
      '';
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8211;
      description = "Game traffic UDP port for Palworld.";
    };

    queryPort = lib.mkOption {
      type = lib.types.port;
      default = 27015;
      description = "Steam server query UDP port.";
    };

    rconPort = lib.mkOption {
      type = lib.types.port;
      default = 25575;
      description = "TCP port for remote console administration (RCON).";
    };

    rconEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable RCON server for external admin tools.";
    };

    players = lib.mkOption {
      type = lib.types.int;
      default = 16;
      description = "Maximum concurrent connected players.";
    };

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Homelab Sandboxed Palworld";
      description = "Server title displayed in the community server browser.";
    };

    serverPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional password required for players to connect.";
    };

    adminPassword = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Password required to authenticate as in-game admin.";
    };

    multithreading = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable multi-core multithreading for enhanced CPU performance.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${parentCfg.stateDir}/palworld";
      description = "Host directory where world saves, player data, and Steam files persist.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open required UDP and TCP ports in the host firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # --------------------------------------------------------------------------
    # OCI Container Definition (Podman)
    # --------------------------------------------------------------------------
    virtualisation.oci-containers.containers."palworld-server" = {
      image = "docker.io/thijsvanloef/palworld-server-docker:latest";
      autoStart = cfg.autoStart;

      ports = [
        "${toString cfg.port}:${toString cfg.port}/udp"
        "${toString cfg.queryPort}:${toString cfg.queryPort}/udp"
      ] ++ lib.optional cfg.rconEnabled "${toString cfg.rconPort}:${toString cfg.rconPort}/tcp";

      volumes = [
        "${cfg.dataDir}:/palworld"
      ];

      environment = {
        PORT = toString cfg.port;
        PLAYERS = toString cfg.players;
        MULTITHREADING = if cfg.multithreading then "true" else "false";
        SERVER_NAME = cfg.serverName;
        SERVER_PASSWORD = if cfg.serverPassword != null then cfg.serverPassword else "";
        ADMIN_PASSWORD = if cfg.adminPassword != null then cfg.adminPassword else "";
        RCON_ENABLED = if cfg.rconEnabled then "true" else "false";
        RCON_PORT = toString cfg.rconPort;
        TZ = config.time.timeZone or "America/Chicago";
      };

      extraOptions = [
        "--security-opt=no-new-privileges:true"
      ];
    };

    # Ensure host save directory exists with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0777 root root -"
    ];

    # Open UDP ports and optional RCON TCP port in firewall
    networking.firewall.allowedUDPPorts = lib.mkIf cfg.openFirewall [ cfg.port cfg.queryPort ];
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.openFirewall && cfg.rconEnabled) [ cfg.rconPort ];
  };
}
