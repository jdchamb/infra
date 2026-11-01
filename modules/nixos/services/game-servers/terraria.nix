# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/terraria.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Sandboxed Terraria Dedicated Server):
#   Deploys an isolated, containerized Terraria dedicated server via Podman.
#   Configured for:
#     - Pure FOSS container runtime (Podman sandbox)
#     - Default port 7777/TCP
#     - Automated world generation on first launch
#     - Persistent state in '/var/lib/game-servers/terraria'
#     - On-demand control ('autoStart = false') so your son can start it via OliveTin
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Running Terraria in an OCI container shields the operating system and guarantees
#   world files, map seeds, and player chests are safely stored on the host's
#   persistent disk across system rebuilds.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.terraria;
in
{
  options.services.fleet.game-servers.terraria = {
    enable = lib.mkEnableOption "Sandboxed Terraria dedicated server";

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
      default = 7777;
      description = "Host TCP port for Terraria player connections.";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum concurrent connected players.";
    };

    worldName = lib.mkOption {
      type = lib.types.str;
      default = "HomelabWorld";
      description = "Name of the Terraria world file.";
    };

    autoCreateWorldSize = lib.mkOption {
      type = lib.types.enum [ "small" "medium" "large" ];
      default = "medium";
      description = "Size of world to auto-generate if world file does not exist.";
    };

    difficulty = lib.mkOption {
      type = lib.types.enum [ "0" "1" "2" "3" ];
      default = "0";
      description = "World difficulty: 0 = Normal, 1 = Expert, 2 = Master, 3 = Journey.";
    };

    password = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional server password required to join.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${parentCfg.stateDir}/terraria";
      description = "Host directory where world saves (.wld) and config persist.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the Terraria TCP port in the host firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # --------------------------------------------------------------------------
    # OCI Container Definition (Podman)
    # --------------------------------------------------------------------------
    virtualisation.oci-containers.containers."terraria-server" = {
      image = "docker.io/beardedio/terraria:latest";
      autoStart = cfg.autoStart;

      ports = [
        "${toString cfg.port}:7777"
      ];

      volumes = [
        "${cfg.dataDir}:/root/.local/share/Terraria/Worlds"
        "${cfg.dataDir}/config:/config"
      ];

      environment = {
        WORLD_NAME = cfg.worldName;
        WORLD_SIZE = if cfg.autoCreateWorldSize == "small" then "1"
                     else if cfg.autoCreateWorldSize == "large" then "3"
                     else "2";
        DIFFICULTY = cfg.difficulty;
        MAX_PLAYERS = toString cfg.maxPlayers;
        SERVER_PORT = "7777";
        PASSWORD = if cfg.password != null then cfg.password else "";
      };

      extraOptions = [
        "--security-opt=no-new-privileges:true"
      ];
    };

    # Ensure host save directories exist before container launch
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0775 root root -"
      "d ${cfg.dataDir}/config 0775 root root -"
    ];

    # Open TCP port in firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
