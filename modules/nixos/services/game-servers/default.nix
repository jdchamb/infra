# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/default.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Sandboxed Game Servers Orchestrator):
#   Acts as the central coordination hub for all game servers running on the host.
#   Integrates Minecraft, Terraria, Palworld, Barotrauma, and custom game servers
#   into a unified, 100% containerized sandbox powered by Podman (pure FOSS).
#
# KEY FEATURES:
#   1. Pure FOSS Containerization (Podman):
#      All servers run inside isolated OCI containers via Podman with no corporate
#      licensing, subscriptions, or telemetry.
#   2. Mutual Exclusion ("One Game at a Time"):
#      Because the Intel NUC has a 15W TDP processor, running only one game at a
#      time ensures 100% of CPU and RAM are dedicated to the active player session.
#      Games share no conflicting ports and have maximum performance.
#   3. State & Save Persistence:
#      Worlds, players, items, and configs live in '/var/lib/game-servers/<game>'
#      and persist untouched through system rebuilds, reboots, and updates.
#   4. Kid-Friendly Web GUI (OliveTin) & Pelican Panel:
#      OliveTin provides 1-click [Play Game] buttons for non-technical users/kids,
#      while Pelican Panel is optionally available for in-game console commands.
#   5. 'game-ctl' CLI:
#      A single administrative CLI tool to switch games, check status, and backup.
#
# HOW TO USE:
#   - Enable on any host (e.g. 'hosts/nixos/nuc-game01/default.nix'):
#       services.fleet.game-servers = {
#         enable = true;
#         minecraft.enable = true;
#         terraria.enable = true;
#         palworld.enable = true;
#         barotrauma.enable = true;
#         gui.olivetin.enable = true;
#       };
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fleet.game-servers;

  # Helper administrative CLI script installed for operators
  gameCtl = pkgs.writeShellScriptBin "game-ctl" ''
    set -euo pipefail

    STATE_DIR="${cfg.stateDir}"
    BACKUP_DIR="${cfg.backupDir}"

    # Recognized unit mapping
    declare -A UNITS=(
      ["minecraft"]="podman-minecraft-server"
      ["terraria"]="podman-terraria-server"
      ["palworld"]="podman-palworld-server"
      ["barotrauma"]="podman-barotrauma-server"
    )

    usage() {
      echo "🎮 Fleet Game Server Control CLI (game-ctl)"
      echo ""
      echo "Usage: game-ctl <command> [game]"
      echo ""
      echo "Commands:"
      echo "  list               List configured game servers and their live state"
      echo "  switch <game>      Stop all other games and start <game> (Mutual Exclusion)"
      echo "  start <game>       Start a specific game server"
      echo "  stop <game>        Stop a specific game server"
      echo "  stop-all           Stop all running game servers immediately"
      echo "  restart <game>     Restart a specific game server"
      echo "  status <game>      Show systemd unit status for <game>"
      echo "  logs <game>        Stream live server logs in real time"
      echo "  backup <game>      Create a timestamped .tar.gz archive of game saves"
      echo ""
      echo "Available Games: minecraft, terraria, palworld, barotrauma (or any custom game)"
      exit 1
    }

    get_unit() {
      local game="''${1:-}"
      if [[ -n "''${UNITS[$game]:-}" ]]; then
        echo "''${UNITS[$game]}"
      else
        echo "podman-game-$game"
      fi
    }

    cmd_list() {
      echo "======================================================================"
      echo "🎮 FLEET GAME SERVERS — SYSTEM STATUS"
      echo "======================================================================"
      printf "%-14s %-12s %-20s %-25s\n" "GAME" "STATUS" "SYSTEMD UNIT" "SAVE DIRECTORY"
      echo "----------------------------------------------------------------------"
      for game in "minecraft" "terraria" "palworld" "barotrauma"; do
        unit=$(get_unit "$game")
        if systemctl is-active --quiet "$unit.service" 2>/dev/null; then
          status="ONLINE 🟢"
        elif systemctl list-unit-files "$unit.service" 2>/dev/null | grep -q "$unit.service"; then
          status="OFFLINE ⚪"
        else
          status="DISABLED ❌"
        fi
        printf "%-14s %-12s %-20s %-25s\n" "$game" "$status" "$unit" "$STATE_DIR/$game"
      done
      echo "======================================================================"
    }

    cmd_stop_all() {
      echo "⏹️ Stopping all running game servers to free CPU & RAM..."
      for game in "minecraft" "terraria" "palworld" "barotrauma"; do
        unit=$(get_unit "$game")
        if systemctl is-active --quiet "$unit.service" 2>/dev/null; then
          echo "  - Stopping $game ($unit)..."
          sudo systemctl stop "$unit.service"
        fi
      done
      echo "✅ All game servers stopped. System resources fully idle."
    }

    cmd_switch() {
      local target="''${1:-}"
      [[ -z "$target" ]] && usage
      local target_unit
      target_unit=$(get_unit "$target")

      echo "🔄 Switching active game session to: $target"
      # Stop all other servers first
      for game in "minecraft" "terraria" "palworld" "barotrauma"; do
        if [[ "$game" != "$target" ]]; then
          unit=$(get_unit "$game")
          if systemctl is-active --quiet "$unit.service" 2>/dev/null; then
            echo "  - Gracefully stopping $game to free resources..."
            sudo systemctl stop "$unit.service"
          fi
        fi
      done

      echo "🚀 Starting $target ($target_unit)..."
      sudo systemctl start "$target_unit.service"
      echo "✅ $target is now running! 100% of CPU and RAM allocated."
    }

    cmd_backup() {
      local game="''${1:-}"
      [[ -z "$game" ]] && usage
      local src="$STATE_DIR/$game"
      if [[ ! -d "$src" ]]; then
        echo "❌ Save directory $src does not exist yet."
        exit 1
      fi
      mkdir -p "$BACKUP_DIR"
      local timestamp
      timestamp=$(date +"%Y%m%d_%H%M%S")
      local dest="$BACKUP_DIR/''${game}_backup_''${timestamp}.tar.gz"
      echo "💾 Archiving $game save directory..."
      sudo tar -czf "$dest" -C "$STATE_DIR" "$game"
      echo "✅ Backup created successfully: $dest"
      ls -lh "$dest"
    }

    ACTION="''${1:-}"
    shift || true

    case "$ACTION" in
      list)       cmd_list ;;
      switch)     cmd_switch "''${1:-}" ;;
      stop-all)   cmd_stop_all ;;
      start)      sudo systemctl start "$(get_unit "''${1:-}").service" ;;
      stop)       sudo systemctl stop "$(get_unit "''${1:-}").service" ;;
      restart)    sudo systemctl restart "$(get_unit "''${1:-}").service" ;;
      status)     systemctl status "$(get_unit "''${1:-}").service" ;;
      logs)       journalctl -u "$(get_unit "''${1:-}").service" -f -n 100 ;;
      backup)     cmd_backup "''${1:-}" ;;
      *)          usage ;;
    esac
  '';
in
{
  # ----------------------------------------------------------------------------
  # IMPORT SUBMODULES
  # ----------------------------------------------------------------------------
  imports = [
    ./minecraft.nix
    ./terraria.nix
    ./palworld.nix
    ./barotrauma.nix
    ./custom.nix
    ./olivetin.nix
    ./pelican.nix
  ];

  # ----------------------------------------------------------------------------
  # OPTION DECLARATIONS: services.fleet.game-servers
  # ----------------------------------------------------------------------------
  options.services.fleet.game-servers = {
    enable = lib.mkEnableOption "Fleet Sandboxed Game Servers orchestration suite";

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/game-servers";
      description = ''
        Root persistent directory on the host where world saves, configs, and player
        progress survive rebuilds, container restarts, and OS updates.
      '';
    };

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backups/game-servers";
      description = ''
        Directory where timestamped game world archive backups are saved.
      '';
    };

    mutualExclusion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        When enabled, ensures only one game server runs at a time to maximize
        CPU core allocation and RAM throughput on the Intel NUC.
      '';
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Automatically open required TCP/UDP ports in the NixOS firewall.";
    };
  };

  # ----------------------------------------------------------------------------
  # CONFIGURATION BLOCK
  # ----------------------------------------------------------------------------
  config = lib.mkIf cfg.enable {
    # 1. Pure FOSS Container Engine (Podman)
    virtualisation.podman = {
      enable = true;
      # dockerCompat creates the 'docker' CLI symlink and enables Docker compatibility
      dockerCompat = true;
      # dockerSocket provides /var/run/docker.sock so Pelican Wings connects effortlessly
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Force oci-containers to use Podman backend
    virtualisation.oci-containers.backend = "podman";

    # 2. Host Directories & Permissions (systemd-tmpfiles)
    # Creates root state and backup directories before services attempt to bind-mount them
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0775 root root -"
      "d ${cfg.backupDir} 0775 root root -"
    ];

    # 3. Impermanence Integration (Stateless Root Compatibility)
    # If the host uses stateless root / impermanence, bind-mount stateDir to /persist
    fileSystems = lib.mkIf (config.services.fleet.impermanence.enable or false) {
      "${cfg.stateDir}" = {
        device = "/persist${cfg.stateDir}";
        fsType = "none";
        options = [ "bind" "X-mount.mkdir" ];
        neededForBoot = false;
      };
      "${cfg.backupDir}" = {
        device = "/persist${cfg.backupDir}";
        fsType = "none";
        options = [ "bind" "X-mount.mkdir" ];
        neededForBoot = false;
      };
    };

    # 4. Operator Tools
    environment.systemPackages = [ gameCtl ];

    # 5. Sudo Privileges for game-ctl operations without typing passwords
    security.sudo.extraRules = [
      {
        users = [ "jchambers" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/systemctl start podman-*";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl stop podman-*";
            options = [ "NOPASSWD" ];
          }
          {
            command = "/run/current-system/sw/bin/systemctl restart podman-*";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
