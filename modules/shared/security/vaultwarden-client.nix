# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/vaultwarden-client.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Services Roadmap Phase 1):
#   Installs the unofficial Rust Bitwarden CLI ('rbw') and official 'bitwarden-cli'
#   across Linux and macOS workstations to authenticate against the self-hosted
#   USD 308 / Homelab Vaultwarden server ('modules/nixos/services/vaultwarden.nix').
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    rbw             # Fast Rust-based Bitwarden/Vaultwarden CLI with background agent
    bitwarden-cli   # Official 'bw' CLI utility for scripted secret retrieval
  ];
}
