# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/palworld.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Palworld):
#   Deploys a dedicated Palworld multiplayer server via OCI container on UDP
#   port 8211 with persistent save state in '/var/lib/palworld'.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."palworld-server" = {
    image = "thijsvanloef/palworld-server-docker:latest";
    ports = [
      "8211:8211/udp"
      "27015:27015/udp"
    ];
    volumes = [
      "/var/lib/palworld:/palworld"
    ];
    environment = {
      TZ = "America/Chicago";
      PORT = "8211";
      PLAYERS = "16";
      MULTITHREADING = "true";
      SERVER_NAME = "Homelab NixOS Palworld";
    };
    autoStart = true;
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/palworld 0755 root root -"
  ];

  networking.firewall.allowedUDPPorts = [ 8211 27015 ];
}
