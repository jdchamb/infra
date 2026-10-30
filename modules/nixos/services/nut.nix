# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/nut.nix (Network UPS Tools)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 15 & Fleet Roadmap Phase 2 — 1-to-1 Module):
#   Configures Network UPS Tools ('power.ups') to monitor battery backup units
#   attached to the home server stack over USB ('usbhid-ups') or SNMP. Exposes
#   a network UPS telemetry listener on port 3493 so downstream lab nodes
#   ('lab-pb01..05') can execute synchronized graceful shutdowns during outages.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   During a power outage, battery backups (UPS) provide only a limited runtime
#   (10 to 30 minutes). If power is not restored before batteries run flat,
#   computers shut down ungracefully, risking filesystem corruption.
#   NUT (Network UPS Tools) monitors the UPS over USB. In 'netserver' mode,
#   this machine broadcasts battery health over port 3493 to other nodes
#   ('netclient' mode). When the battery reaches a critical threshold, all
#   nodes shut down safely and cleanly.
#
# HOW TO USE:
#   - Default behavior when imported: Enabled in 'netserver' mode.
#   - To configure as a follower on a client laptop or lab node:
#       services.fleet.nut.mode = "netclient";
#   - CLI status check:
#       upsc homelab-ups@localhost
#
# >>> SECURITY WARNING (READ BEFORE DEPLOYING) <<<
#   The systemd.tmpfiles rule seeds a default password ('changeme-nut-local')
#   for the internal 'upsmon' monitor daemon. This password is only used locally
#   between upsd and upsmon, but should be replaced via SOPS-Nix for production.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fleet.nut;
in
{
  # Declarative configuration options for the fleet NUT abstraction
  options.services.fleet.nut = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Network UPS Tools (NUT) power monitoring daemon.";
    };

    mode = lib.mkOption {
      type = lib.types.enum [ "standalone" "netserver" "netclient" ];
      default = "netserver";
      description = "NUT operational role ('standalone', 'netserver' for UPS host, or 'netclient' for follower nodes).";
    };

    upsName = lib.mkOption {
      type = lib.types.str;
      default = "homelab-ups";
      description = "Logical identifier for the primary homelab UPS unit.";
    };

    driver = lib.mkOption {
      type = lib.types.str;
      default = "usbhid-ups";
      description = "NUT hardware driver (e.g., 'usbhid-ups' for APC/CyberPower/Eaton USB, or 'snmp-ups').";
    };
  };

  config = lib.mkIf cfg.enable {
    power.ups = {
      enable = true;
      mode = cfg.mode;

      # Define the physical UPS hardware device (only when running as server/standalone)
      ups.${cfg.upsName} = lib.mkIf (cfg.mode != "netclient") {
        driver = cfg.driver;
        port = "auto"; # Automatically scan USB buses for compatible HID devices
        description = "Homelab Primary Battery Backup Unit";
      };

      # Telemetry daemon listener: listen on 0.0.0.0 if acting as server for clients
      upsd.listen = [
        {
          address = if cfg.mode == "netserver" then "0.0.0.0" else "127.0.0.1";
          port = 3493;
        }
      ];

      # Local monitoring daemon: triggers graceful shutdown scripts on critical battery
      upsmon.monitor.${cfg.upsName} = {
        system = "${cfg.upsName}@localhost";
        powerValue = 1;
        user = "upsmon";
        passwordFile = "/etc/nixos/secrets/nut-upsmon-pass";
        type = if cfg.mode == "netclient" then "secondary" else "primary";
      };
    };

    # Ensure upsmon password file exists (0600 mode = root-only)
    systemd.tmpfiles.rules = [
      "f /etc/nixos/secrets/nut-upsmon-pass 0600 root root - changeme-nut-local"
    ];

    # Open port 3493 only when configured to serve remote client followers
    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.mode == "netserver") [ 3493 ];

    # Install the 'upsc' and 'upscmd' command-line utilities
    environment.systemPackages = [ pkgs.nut ];
  };
}
