# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/vaultwarden-client.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 & Fleet Services Roadmap Phase 1):
#   Installs the unofficial Rust Bitwarden CLI ('rbw') and official 'bitwarden-cli'
#   across Linux and macOS workstations to authenticate against our self-hosted
#   USD 308 / Homelab Vaultwarden server ('modules/nixos/services/vaultwarden.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Instead of copying and pasting passwords from a web browser into terminal
#   scripts, CLI password clients let you securely fetch credentials directly
#   inside your shell or automation scripts:
#     - 'rbw': A fast, community Rust client for Bitwarden/Vaultwarden that runs
#       a lightweight background agent so you don't have to re-type your master
#       password on every command.
#     - 'bitwarden-cli' ('bw'): The official Bitwarden command-line tool, useful
#       for exporting/importing vaults and managing organizational collections.
#
# QUICK USAGE CHEAT SHEET:
#   - 'rbw config set base_url https://vault.example.com' : Point to Vaultwarden
#   - 'rbw config set email joshua@chambers-net.org'      : Set account email
#   - 'rbw login && rbw unlock'                           : Authenticate & unlock
#   - 'rbw get <item-name>'                               : Print password to stdout
# ==============================================================================

{ pkgs, ... }:

{
  # Install both 'rbw' and official 'bw' CLI tools on Linux and macOS
  environment.systemPackages = with pkgs; [
    rbw             # Fast Rust-based Bitwarden/Vaultwarden CLI with background agent
    bitwarden-cli   # Official 'bw' CLI utility for scripted secret & org management
  ];
}
