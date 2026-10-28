# ==============================================================================
# SHARED MODULE: modules/shared/ghostty.nix (GPU-Accelerated Terminal Emulator)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Deploys Ghostty terminal configuration and packages across the fleet.
#   - On Linux (NixOS): Installs 'pkgs.ghostty' via systemPackages.
#   - On macOS (Darwin): Ghostty is installed as a native GUI Cask in Homebrew.
#     The Linux package is omitted on Darwin to prevent build errors.
#   - User Configuration: Generates '~/.config/ghostty/config.ghostty' with
#     Catppuccin Mocha theme, JetBrains Mono font, and 95% opacity.
# ==============================================================================

{ pkgs, lib, ... }:

{
  # Only install the Nix package on Linux nodes (macOS uses Homebrew Cask)
  environment.systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.ghostty
  ];

  # Declarative configuration file shared across all platforms
  home-manager.users.jchambers.home.file.".config/ghostty/config.ghostty".text = ''
    # Typography
    font-family = JetBrains Mono
    font-size = 14

    # Visual Theme & Transparency
    theme = Catppuccin Mocha
    background-opacity = 0.95
  '';
}

