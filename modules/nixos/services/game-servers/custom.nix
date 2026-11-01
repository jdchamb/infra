# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/custom.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Extensible Game Server Engine):
#   Allows declaring ANY other game server (Valheim, Factorio, Satisfactory,
#   Rust, Enshrouded, 7 Days to Die, Project Zomboid, etc.) purely from your Nix
#   Flake using sandboxed OCI containers.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Instead of writing a completely new NixOS module for every new game that comes
#   out, 'customServers' lets you declare any containerized game server in a few
#   lines of code with automatic persistent volumes, firewall port opening, and
#   on-demand OliveTin controls.
#
# EXAMPLE USAGE IN HOST CONFIGURATION:
#   services.fleet.game-servers.customServers."valheim" = {
#     enable = true;
#     autoStart = false;
#     image = "docker.io/lloesche/valheim-server:latest";
#     ports = [ "2456-2457:2456-2457/udp" ];
#     udpPorts = [ 2456 2457 ];
#     environment = {
#       SERVER_NAME = "Homelab Valheim";
#       WORLD_NAME = "Midgard";
#       SERVER_PASS = "SecretPassword";
#     };
#   };
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  parentCfg = config.services.fleet.game-servers;

  customServerSubmodule = { name, ... }: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable this custom game server instance.";
      };

      autoStart = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to start the server automatically on system boot.";
      };

      image = lib.mkOption {
        type = lib.types.str;
        description = "OCI container image to deploy (e.g. 'docker.io/factoriotools/factorio:stable').";
      };

      ports = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Port mappings to expose on the host (e.g. [ '34197:34197/udp' ]).";
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf (lib.types.either lib.types.str (lib.types.either lib.types.int lib.types.bool));
        default = { };
        description = "Environment variables passed into the container.";
      };

      volumes = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "${parentCfg.stateDir}/custom/${name}:/data" ];
        description = "Persistent host volume mappings.";
      };

      tcpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "TCP ports to open in the host firewall.";
      };

      udpPorts = lib.mkOption {
        type = lib.types.listOf lib.types.port;
        default = [ ];
        description = "UDP ports to open in the host firewall.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Automatically open the specified TCP and UDP ports in the firewall.";
      };

      extraOptions = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "--security-opt=no-new-privileges:true" ];
        description = "Extra arguments passed to the container runtime.";
      };
    };
  };
in
{
  options.services.fleet.game-servers.customServers = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule customServerSubmodule);
    default = { };
    description = "Extensible map of custom containerized game servers.";
  };

  config = lib.mkIf parentCfg.enable {
    # Generate OCI container definitions for every enabled custom server
    virtualisation.oci-containers.containers = lib.mapAttrs' (name: srv:
      lib.nameValuePair "game-${name}" {
        image = srv.image;
        autoStart = srv.autoStart;
        ports = srv.ports;
        volumes = srv.volumes;
        environment = lib.mapAttrs (k: v: toString v) srv.environment;
        extraOptions = srv.extraOptions;
      }
    ) (lib.filterAttrs (n: s: s.enable) parentCfg.customServers);

    # Ensure persistent directories exist
    systemd.tmpfiles.rules = lib.concatLists (lib.mapAttrsToList (name: srv:
      [ "d ${parentCfg.stateDir}/custom/${name} 0777 root root -" ]
    ) (lib.filterAttrs (n: s: s.enable) parentCfg.customServers));

    # Open firewall ports
    networking.firewall.allowedTCPPorts = lib.concatLists (lib.mapAttrsToList (name: srv:
      lib.optionals srv.openFirewall srv.tcpPorts
    ) (lib.filterAttrs (n: s: s.enable) parentCfg.customServers));

    networking.firewall.allowedUDPPorts = lib.concatLists (lib.mapAttrsToList (name: srv:
      lib.optionals srv.openFirewall srv.udpPorts
    ) (lib.filterAttrs (n: s: s.enable) parentCfg.customServers));
  };
}
