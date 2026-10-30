# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/home-assistant.nix (Smart Home)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 16 & Fleet Roadmap Phase 4 — 1-to-1 Module):
#   Deploys Home Assistant ('services.home-assistant') on port 8123 with built-in
#   components for Reolink PoE Doorbell cameras ('reolink'), NUT UPS telemetry
#   ('nut'), and local automation orchestration.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;
    openFirewall = true;
    extraComponents = [
      "default_config"
      "met"
      "esphome"
      "reolink"
      "nut"
    ];
    config = {
      default_config = {};
      http = {
        server_port = 8123;
      };
    };
  };
}
