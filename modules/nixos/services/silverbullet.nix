# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/silverbullet.nix (Technical Wiki)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 8 & Fleet Roadmap Phase 3 — 1-to-1 Module):
#   Deploys SilverBullet ('services.silverbullet'), an extensible, local-first
#   Markdown technical wiki and knowledge base on port 3002 for USD 308
#   Technology Department documentation and homelab runbooks.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   SilverBullet is an open-source knowledge management tool that saves all pages
#   as pure, clean Markdown files in a local folder ('/var/lib/silverbullet').
#   It runs in any web browser and supports live queries, interactive tables,
#   and offline sync. Because files are plain Markdown, your notes are never
#   locked inside a proprietary database.
#
# HOW TO USE:
#   - Importing this module turns SilverBullet ON immediately.
#   - Web interface: http://<host-ip>:3002
#   - Notes are stored in '/var/lib/silverbullet' and can be edited via the web
#     UI or backed up with BorgBackup ('modules/nixos/services/backup-borg.nix').
#
# PORT NOTICE:
#   - Listens on TCP port 3002.
#   - Compare with Forgejo (port 3001), Planka (port 3003), and AdGuard Home (port 3000).
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  services.silverbullet = {
    enable = true;
    spaceDir = "/var/lib/silverbullet"; # Root directory containing all Markdown notes
    listenPort = 3002;                  # HTTP port for the web interface
    listenAddress = "0.0.0.0";          # Bind to all network interfaces for LAN access
    openFirewall = true;                # Open port 3002 in the NixOS firewall
  };
}
