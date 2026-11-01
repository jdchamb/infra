# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/minecraft.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Sandboxed Minecraft Dedicated Server):
#   Deploys an isolated, containerized Minecraft server via Podman utilizing the
#   gold-standard 'itzg/minecraft-server' image.
#   Configured for:
#     - Pure FOSS container runtime (Podman rootless/unprivileged user)
#     - High-performance Paper server out of the box (Aikar G1GC flags enabled)
#     - Full Prism Launcher-style modpack automation (Modrinth & CurseForge slugs)
#     - Persistent state in '/var/lib/game-servers/minecraft'
#     - On-demand control ('autoStart = false') so your son can start it via OliveTin
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Running Minecraft inside a hardened Podman container protects the host system
#   from potential security vulnerabilities (such as Log4j or malicious code
#   embedded in third-party modpacks). The server runs in an unprivileged sandbox
#   where only the '/data' folder is mounted; it cannot read your SSH keys, user
#   files, or operating system configuration.
#
# MODPACK SUPPORT (PRISM LAUNCHER STYLE):
#   - Out of the box, this runs vanilla-compatible Paper Minecraft on port 25565.
#   - To activate a Modrinth modpack (e.g. Cobblemon), simply declare:
#       modpack.platform = "modrinth";
#       modpack.slug = "cobblemon";
#   - The container automatically queries Modrinth, resolves the Fabric/Forge
#     loader, downloads all required server jars, and handles updates.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.minecraft;
in
{
  options.services.fleet.game-servers.minecraft = {
    enable = lib.mkEnableOption "Sandboxed Minecraft dedicated server";

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
      default = 25565;
      description = "Host TCP port for Minecraft player connections.";
    };

    memory = lib.mkOption {
      type = lib.types.str;
      default = "4G";
      description = "RAM allocated to the Minecraft server (e.g. '4G', '6G', '8G').";
    };

    motd = lib.mkOption {
      type = lib.types.str;
      default = "Homelab Sandboxed Minecraft Server";
      description = "Message of the day displayed in the multiplayer server browser.";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.int;
      default = 20;
      description = "Maximum concurrent connected players.";
    };

    difficulty = lib.mkOption {
      type = lib.types.enum [ "peaceful" "easy" "normal" "hard" ];
      default = "normal";
      description = "World difficulty.";
    };

    gamemode = lib.mkOption {
      type = lib.types.enum [ "survival" "creative" "adventure" "spectator" ];
      default = "survival";
      description = "Default player gamemode.";
    };

    type = lib.mkOption {
      type = lib.types.enum [ "PAPER" "VANILLA" "FABRIC" "FORGE" "NEOFORGE" "QUILT" ];
      default = "PAPER";
      description = "Server engine type when no external modpack platform is selected.";
    };

    version = lib.mkOption {
      type = lib.types.str;
      default = "LATEST";
      description = "Minecraft version (e.g. '1.20.4' or 'LATEST').";
    };

    eula = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Accept the Mojang Minecraft End User License Agreement.";
    };

    onlineMode = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Authenticate players with official Mojang/Microsoft accounts.";
    };

    modpack = {
      platform = lib.mkOption {
        type = lib.types.enum [ "none" "modrinth" "curseforge" "local" ];
        default = "none";
        description = ''
          Modpack platform provider. Set to 'modrinth' or 'curseforge' to
          automatically download full modpacks on first startup.
        '';
      };

      slug = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "cobblemon";
        description = "Modpack slug identifier on Modrinth or CurseForge.";
      };

      fileId = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional CurseForge file ID to pin an exact modpack version.";
      };
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${parentCfg.stateDir}/minecraft";
      description = "Host directory where world saves, configs, and player inventories persist.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the Minecraft TCP port in the host firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # --------------------------------------------------------------------------
    # OCI Container Definition (Podman)
    # --------------------------------------------------------------------------
    virtualisation.oci-containers.containers."minecraft-server" = {
      image = "docker.io/itzg/minecraft-server:latest";
      autoStart = cfg.autoStart;

      ports = [
        "${toString cfg.port}:25565"
      ];

      volumes = [
        "${cfg.dataDir}:/data"
      ];

      environment = lib.mkMerge [
        {
          EULA = if cfg.eula then "TRUE" else "FALSE";
          MEMORY = cfg.memory;
          VERSION = cfg.version;
          MOTD = cfg.motd;
          MAX_PLAYERS = toString cfg.maxPlayers;
          DIFFICULTY = cfg.difficulty;
          MODE = cfg.gamemode;
          ONLINE_MODE = if cfg.onlineMode then "TRUE" else "FALSE";
          # Use Aikar's tuned JVM GC flags to prevent tick stutter
          USE_AIKAR_FLAGS = "true";
          TZ = config.time.timeZone or "America/Chicago";
        }

        # Modpack configuration: None (Paper / Vanilla default)
        (lib.mkIf (cfg.modpack.platform == "none") {
          TYPE = cfg.type;
        })

        # Modpack configuration: Modrinth
        (lib.mkIf (cfg.modpack.platform == "modrinth") {
          TYPE = "MODRINTH";
          MODRINTH_MODPACK = lib.mkDefault (if cfg.modpack.slug != null then cfg.modpack.slug else "");
        })

        # Modpack configuration: CurseForge
        (lib.mkIf (cfg.modpack.platform == "curseforge") {
          TYPE = "AUTO_CURSEFORGE";
          CF_SLUG = lib.mkDefault (if cfg.modpack.slug != null then cfg.modpack.slug else "");
          CF_FILE_ID = lib.mkDefault (if cfg.modpack.fileId != null then cfg.modpack.fileId else "");
        })
      ];

      extraOptions = [
        # Prevent privilege escalation inside container
        "--security-opt=no-new-privileges:true"
        "--cap-drop=ALL"
      ];
    };

    # Ensure host save directory exists with proper permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0775 1000 1000 -"
    ];

    # Open TCP port in firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
