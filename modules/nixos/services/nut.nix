# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/nut.nix (Network UPS Tools)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 15 & Fleet Roadmap Phase 2 — 1-to-1 Module):
#   Configures Network UPS Tools ('power.ups') to monitor battery backup units
#   attached to the home server stack over USB ('usbhid-ups') or SNMP. Exposes
#   a network UPS telemetry listener on port 3493 so downstream lab nodes
#   ('lab-pb01..05') can execute synchronized graceful shutdowns during outages.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  cfg = config.services.fleet.nut;
in
{
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

      ups.${cfg.upsName} = lib.mkIf (cfg.mode != "netclient") {
        driver = cfg.driver;
        port = "auto";
        description = "Homelab Primary Battery Backup Unit";
      };

      upsd.listen = [
        {
          address = if cfg.mode == "netserver" then "0.0.0.0" else "127.0.0.1";
          port = 3493;
        }
      ];

      upsmon.monitor.${cfg.upsName} = {
        system = "${cfg.upsName}@localhost";
        powerValue = 1;
        user = "upsmon";
        passwordFile = "/etc/nixos/secrets/nut-upsmon-pass";
        type = if cfg.mode == "netclient" then "secondary" else "primary";
      };
    };

    systemd.tmpfiles.rules = [
      "f /etc/nixos/secrets/nut-upsmon-pass 0600 root root - changeme-nut-local"
    ];

    networking.firewall.allowedTCPPorts = lib.mkIf (cfg.mode == "netserver") [ 3493 ];

    environment.systemPackages = [ pkgs.nut ];
  };
}
