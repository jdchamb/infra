# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/home-assistant.nix (Smart Home)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 16 & Fleet Roadmap Phase 4 — 1-to-1 Module):
#   Deploys Home Assistant ('services.home-assistant') on port 8123 with built-in
#   components for Reolink PoE Doorbell cameras ('reolink'), NUT UPS telemetry
#   ('nut'), ESPHome IoT devices, and local automation orchestration.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Home Assistant is an open-source home automation hub that runs entirely
#   on your local network without relying on third-party cloud servers.
#   It coordinates sensors, switches, power monitors (NUT), and PoE cameras
#   (Reolink) into unified dashboards, notifications, and automated triggers.
#
# HOW TO USE:
#   - Importing this module turns Home Assistant ON immediately.
#   - Web interface: http://<host-ip>:8123
#   - First-time setup: browse to the URL and complete the onboarding wizard.
#   - Integrations for Reolink cameras and NUT battery telemetry will be
#     discoverable under Settings -> Devices & Services.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.home-assistant = {
    enable = true;
    openFirewall = true; # Open TCP port 8123 in the firewall

    # Python packages / component dependencies to preload into Home Assistant
    extraComponents = [
      "default_config" # Core standard component suite
      "met"            # Default weather integration
      "esphome"        # Native API for custom ESP8266/ESP32 microcontrollers
      "reolink"        # Direct LAN API and RTSP streaming for Reolink doorbells/cameras
      "nut"            # Network UPS Tools integration for monitoring battery runtime
    ];

    config = {
      default_config = {};
      http = {
        server_port = 8123; # Default Home Assistant HTTP port
      };
    };
  };
}
