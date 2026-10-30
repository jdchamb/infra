# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/forgejo.nix (Self-Hosted Git Forge)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 24 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys a self-hosted Forgejo Git forge (the open-source engine powering
#   Codeberg.org) on port 3001. Can act as an internal USD 308 / homelab Git
#   server and automatic pull-mirror for Codeberg repositories.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Forgejo is a lightweight, fully-featured Git platform (like GitHub or GitLab)
#   that runs easily on modest hardware. It includes repository hosting, code
#   review (pull requests), issue tracking, Git LFS (Large File Storage), and
#   CI/CD Actions runners.
#
# HOW TO USE:
#   - Importing this module turns Forgejo ON immediately.
#   - Web interface: http://<host-ip>:3001
#   - The first account created in the web UI automatically receives
#     server administrator privileges.
#
# PORT & ROUTING NOTE:
#   - Listens on TCP port 3001 (AdGuard Home uses port 3000 by default, avoiding
#     a direct collision).
#   - If accessed via reverse proxy or domain, ensure 'DOMAIN' and 'ROOT_URL'
#     match your public hostname.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.forgejo = {
    enable = true;
    # Lightweight embedded SQLite database engine; zero external database setup required
    database.type = "sqlite3";
    # Enable Git Large File Storage for tracking ISOs, firmware, and binary assets
    lfs.enable = true;

    settings = {
      server = {
        DOMAIN = "git.homelab.local";
        HTTP_PORT = 3001;
        ROOT_URL = "http://git.homelab.local:3001/";
      };
      service = {
        # Disable open public registration to prevent unwanted accounts
        DISABLE_REGISTRATION = true;
      };
      actions = {
        # Enable built-in Forgejo Actions (compatible with GitHub Actions workflows)
        ENABLED = true;
      };
    };
  };

  # Open TCP port 3001 in the firewall for incoming HTTP traffic
  networking.firewall.allowedTCPPorts = [ 3001 ];
}
