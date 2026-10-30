# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/bitwarden.nix (Bitwarden Desktop Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Roadmap Phase 1 — 1-to-1 Module):
#   Installs the Bitwarden Desktop GUI application to connect to the centralized
#   USD 308 / Homelab Vaultwarden server ('modules/nixos/services/vaultwarden.nix').
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.bitwarden-desktop
  ];
}
