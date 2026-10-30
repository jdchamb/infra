# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/game-servers/minecraft.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 5 — 1-to-1 Module for Minecraft):
#   Configures a declarative Minecraft server ('services.minecraft-server') on
#   port 25565 with optimized Aikars JVM garbage-collection flags.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;
    jvmOpts = "-Xms4G -Xmx4G -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200";
    serverProperties = {
      server-port = 25565;
      motd = "Homelab Declarative NixOS Minecraft Server";
      max-players = 20;
      view-distance = 12;
      online-mode = true;
    };
  };
}
