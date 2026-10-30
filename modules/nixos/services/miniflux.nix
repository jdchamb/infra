# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/miniflux.nix (Miniflux RSS Reader)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Miniflux):
#   Deploys Miniflux ('services.miniflux'), a minimalist, keyboard-driven RSS
#   and Atom feed reader backed by PostgreSQL on port 8088.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    adminCredentialsFile = "/etc/nixos/secrets/miniflux-admin";
    config = {
      LISTEN_ADDR = "0.0.0.0:8088";
      CLEANUP_FREQUENCY = 48;
    };
  };

  systemd.tmpfiles.rules = [
    "f /etc/nixos/secrets/miniflux-admin 0600 root root - ADMIN_USERNAME=jchambers\nADMIN_PASSWORD=changeme-miniflux"
  ];

  networking.firewall.allowedTCPPorts = [ 8088 ];
}
