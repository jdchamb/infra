# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/miniflux.nix (Miniflux RSS Reader)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 4 — 1-to-1 Module for Miniflux):
#   Deploys Miniflux ('services.miniflux'), a minimalist, keyboard-driven RSS
#   and Atom feed reader backed by PostgreSQL on port 8088.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   RSS lets you follow blogs, release notes (e.g. NixOS, Forgejo), and news
#   sites in one place without algorithms or ads. Miniflux is a tiny, fast web
#   app for reading those feeds. NixOS automatically creates and manages the
#   PostgreSQL database it needs.
#
# HOW TO USE:
#   - Importing this module turns Miniflux ON immediately.
#   - Browse to http://<host-ip>:8088 and log in as 'jchambers'.
#
# >>> SECURITY WARNING (READ BEFORE DEPLOYING) <<<
#   The tmpfiles rule below seeds a PLACEHOLDER admin password
#   ('changeme-miniflux'). Two problems with leaving it as-is:
#     1. Anyone who reads this public repo knows the password.
#     2. Text written inside a .nix file is copied into /nix/store, which is
#        world-readable on the machine.
#   Before real use: change the password in the Miniflux UI right after first
#   login, and ideally replace this rule with a sops-nix secret
#   (see 'modules/nixos/core/sops.nix').
#   Note: 'f' rules only create the file if it does NOT already exist, so
#   editing the file on disk afterwards will not be overwritten on rebuild.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.miniflux = {
    enable = true;
    # File containing ADMIN_USERNAME / ADMIN_PASSWORD used to create the first admin
    adminCredentialsFile = "/etc/nixos/secrets/miniflux-admin";
    config = {
      LISTEN_ADDR = "0.0.0.0:8088"; # Listen on all interfaces, port 8088
      CLEANUP_FREQUENCY = 48;       # Hours between automatic old-entry cleanups
    };
  };

  # Seed the credentials file (mode 0600 = readable only by root). See WARNING above.
  systemd.tmpfiles.rules = [
    "f /etc/nixos/secrets/miniflux-admin 0600 root root - ADMIN_USERNAME=jchambers\nADMIN_PASSWORD=changeme-miniflux"
  ];

  # Miniflux has no 'openFirewall' option, so open the port manually
  networking.firewall.allowedTCPPorts = [ 8088 ];
}
