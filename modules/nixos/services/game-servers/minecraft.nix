# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/minecraft.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Minecraft):
#   Configures a declarative Minecraft server ('services.minecraft-server') on
#   port 25565 with tuned G1 garbage-collection JVM flags.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Minecraft Java Edition servers are Java programs. NixOS's built-in module
#   handles downloading the server, creating a service user, and running it as
#   a systemd service. With 'declarative = true', the settings below are written
#   into 'server.properties' on every rebuild, so the config lives in Git
#   instead of being hand-edited on the server.
#
# HOW TO USE:
#   - Importing this module starts the server immediately.
#   - Players connect to <host-ip>:25565 from Minecraft Java Edition.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    # You must accept Mojang's EULA (https://aka.ms/MinecraftEULA) to run a server.
    # Setting this to true means you have read and agree to it.
    eula = true;
    openFirewall = true; # Open TCP 25565 in the NixOS firewall
    declarative = true;  # Manage server.properties from Nix (overwrites manual edits)

    # Java memory & garbage-collector tuning:
    #   -Xms4G / -Xmx4G  : Start and cap the heap at 4 GB (equal values avoid resize stutter)
    #   -XX:+UseG1GC     : Low-pause G1 garbage collector, good for game servers
    #   -XX:MaxGCPauseMillis=200 : Ask the GC to keep pauses under 200 ms (reduces lag spikes)
    jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";

    serverProperties = {
      server-port = 25565;                                 # Default Minecraft port
      motd = "Homelab Declarative NixOS Minecraft Server"; # Message shown in server list
      max-players = 20;
      view-distance = 12;  # Chunks rendered around each player (higher = more CPU/RAM)
      online-mode = true;  # Verify players with Mojang accounts (prevents impersonation)
    };
  };
}
