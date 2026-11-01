# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/olivetin.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Kid-Friendly Game Server Dashboard):
#   Deploys OliveTin ('services.olivetin') on port 1337, providing an intuitive,
#   accessible web interface with big action cards and buttons for starting,
#   stopping, switching, and backing up game servers.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Command-line tools (SSH, systemctl, game-ctl) are intimidating for children
#   and family members. OliveTin provides a clean, colorful webpage accessible
#   from any iPad, smartphone, or laptop browser on the local network.
#   - Your son simply taps "Play Minecraft" or "Play Palworld".
#   - OliveTin invokes 'game-ctl switch <game>' behind the scenes, automatically
#     stopping other games to guarantee 100% of CPU and RAM for the active game.
#   - Sudo access is strictly restricted to 'game-ctl', so there is zero risk of
#     anyone accidentally breaking operating system settings.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;
  cfg = parentCfg.gui.olivetin;

  # Build action items dynamically based on enabled game servers
  playActions = lib.flatten [
    (lib.optional parentCfg.minecraft.enable {
      title = "🎮 Play Minecraft";
      icon = "pickaxe";
      shell = "sudo /run/current-system/sw/bin/game-ctl switch minecraft";
      timeout = 60;
    })
    (lib.optional parentCfg.terraria.enable {
      title = "🎮 Play Terraria";
      icon = "tree";
      shell = "sudo /run/current-system/sw/bin/game-ctl switch terraria";
      timeout = 45;
    })
    (lib.optional parentCfg.palworld.enable {
      title = "🎮 Play Palworld";
      icon = "paw";
      shell = "sudo /run/current-system/sw/bin/game-ctl switch palworld";
      timeout = 90;
    })
    (lib.optional parentCfg.barotrauma.enable {
      title = "🎮 Play Barotrauma";
      icon = "submarine";
      shell = "sudo /run/current-system/sw/bin/game-ctl switch barotrauma";
      timeout = 60;
    })
  ];

  backupActions = lib.flatten [
    (lib.optional parentCfg.minecraft.enable {
      title = "💾 Backup Minecraft World";
      icon = "save";
      shell = "sudo /run/current-system/sw/bin/game-ctl backup minecraft";
      timeout = 120;
    })
    (lib.optional parentCfg.terraria.enable {
      title = "💾 Backup Terraria World";
      icon = "save";
      shell = "sudo /run/current-system/sw/bin/game-ctl backup terraria";
      timeout = 120;
    })
    (lib.optional parentCfg.palworld.enable {
      title = "💾 Backup Palworld World";
      icon = "save";
      shell = "sudo /run/current-system/sw/bin/game-ctl backup palworld";
      timeout = 120;
    })
    (lib.optional parentCfg.barotrauma.enable {
      title = "💾 Backup Barotrauma World";
      icon = "save";
      shell = "sudo /run/current-system/sw/bin/game-ctl backup barotrauma";
      timeout = 120;
    })
  ];

  stopAction = [
    {
      title = "⏹️ Stop All Games (Free CPU & RAM)";
      icon = "stop";
      shell = "sudo /run/current-system/sw/bin/game-ctl stop-all";
      timeout = 30;
    }
  ];
in
{
  options.services.fleet.game-servers.gui.olivetin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable kid-friendly OliveTin push-button web dashboard on port 1337.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 1337;
      description = "Web dashboard port for OliveTin.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the OliveTin web port in the NixOS firewall.";
    };
  };

  config = lib.mkIf (parentCfg.enable && cfg.enable) {
    # Permit OliveTin package in nixpkgs (LAN-only kid-friendly dashboard)
    nixpkgs.config.permittedInsecurePackages = [
      "olivetin-2025.11.25"
    ];

    # --------------------------------------------------------------------------
    # OliveTin Service Configuration
    # --------------------------------------------------------------------------
    services.olivetin = {
      enable = true;
      settings = {
        listenPort = cfg.port;
        listenAddress = "0.0.0.0";
        dashboardTitle = "🎮 Homelab Game Servers";
        actions = playActions ++ stopAction ++ backupActions;
      };
    };

    # Grant OliveTin user scoped sudo access exclusively for game-ctl commands
    security.sudo.extraRules = [
      {
        users = [ "olivetin" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/game-ctl *";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # Open web dashboard port in host firewall
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];
  };
}
