# ==============================================================================
# COMMON MODULE: modules/common/fonts.nix (System-Wide Typography & Nerd Fonts)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs the patched JetBrains Mono and Fira Code Nerd Fonts across the
#   system font cache so terminal emulators (Ghostty), multiplexers (Zellij),
#   prompts (Starship), and status bars (Waybar/Noctalia) render glyphs cleanly.
# ==============================================================================

{ config, pkgs, ... }:

{
  # Uses the modern nixos-unstable structured 'nerd-fonts.<name>' attribute namespace
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];
}
