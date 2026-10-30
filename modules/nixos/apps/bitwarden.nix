# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/bitwarden.nix (Bitwarden Desktop Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Roadmap Phase 1 — 1-to-1 Module):
#   Installs the Bitwarden Desktop GUI application to connect to the centralized
#   USD 308 / Homelab Vaultwarden server ('modules/nixos/services/vaultwarden.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Vaultwarden (our self-hosted password server) speaks the exact same API as
#   official Bitwarden. By installing 'bitwarden-desktop' on our Linux
#   workstations and pointing its server URL to our local Vaultwarden instance,
#   we get a full graphical password manager with zero cloud subscription fees.
# ==============================================================================

{ pkgs, ... }:

{
  # Install the graphical Bitwarden Desktop app into the system PATH and app launcher
  environment.systemPackages = [
    pkgs.bitwarden-desktop
  ];
}
