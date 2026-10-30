# ==============================================================================
# COMMON MODULE: modules/common/fonts.nix (System-Wide Typography & Nerd Fonts)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs the patched JetBrains Mono and Fira Code Nerd Fonts across the
#   system font cache so terminal emulators (Ghostty), multiplexers (Zellij),
#   prompts (Starship), and status bars (Waybar/Noctalia) render glyphs cleanly.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Modern terminal tools (like our Starship prompt, 'eza' file icons, and
#   Lazygit/Neovim UIs) use special Unicode characters for folder icons, Git
#   branch symbols, and OS logos. Standard system fonts do not include these
#   symbols and would display ugly empty boxes ("tofu" rectangles) instead.
#   "Nerd Fonts" are developer fonts patched with thousands of vector icons.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 'fonts.packages' registers font derivations into the OS font directory
  # (/run/current-system/sw/share/X11/fonts on NixOS, /Library/Fonts/Nix Fonts on macOS).
  # Note: nixos-unstable uses the structured 'nerd-fonts.<name>' attribute set.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono # Primary monospace font used in Ghostty & KDE Plasma
    nerd-fonts.fira-code      # Secondary monospace font with programming ligatures
  ];
}
