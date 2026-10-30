# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/palworld.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Palworld):
#   Deploys a dedicated Palworld multiplayer server via OCI container on UDP
#   port 8211 with persistent save state in '/var/lib/palworld'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   The Palworld dedicated server is a Windows/Linux binary distributed through
#   Steam (SteamCMD) and is not packaged in Nixpkgs. A community container image
#   bundles SteamCMD and handles downloads/updates for us, and NixOS's
#   'oci-containers' runs that container as a normal systemd service.
#
# HOW TO USE:
#   - Importing this module starts the container immediately (first start
#     downloads several GB of game files, so give it time).
#   - Players connect to <host-ip>:8211 from the in-game server browser.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  virtualisation.oci-containers.containers."palworld-server" = {
    image = "thijsvanloef/palworld-server-docker:latest";
    ports = [
      "8211:8211/udp"   # Game traffic (Palworld uses UDP, not TCP)
      "27015:27015/udp" # Steam server query port (lets the server appear in browsers)
    ];
    volumes = [
      # Persist world saves and server files on the host disk
      "/var/lib/palworld:/palworld"
    ];
    environment = {
      TZ = "America/Chicago";
      PORT = "8211";
      PLAYERS = "16";                       # Max concurrent players
      MULTITHREADING = "true";              # Use multiple CPU cores
      SERVER_NAME = "Homelab NixOS Palworld";
    };
    autoStart = true;
  };

  # Ensure the save directory exists before the container starts
  systemd.tmpfiles.rules = [
    "d /var/lib/palworld 0755 root root -"
  ];

  # Open the UDP game and query ports to the LAN
  networking.firewall.allowedUDPPorts = [ 8211 27015 ];
}
