# ==============================================================================
# SHARED MODULE: modules/shared/ghostty.nix (GPU-Accelerated Terminal Emulator)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 7):
#   Deploys Ghostty terminal configuration and packages across the fleet,
#   implementing the Universal Environment Keybinding Pattern:
#     - Super (Mod4): Reserved for the Wayland Compositor (Hyprland/Niri/Sway)
#     - Alt: Reserved for Terminal Multiplexing (Zellij panes/tabs)
#     - Ctrl+Shift: Dedicated to Ghostty native window/split/clipboard actions
#   - On Linux (NixOS): Installs 'pkgs.ghostty' via systemPackages.
#   - On macOS (Darwin): Ghostty is installed via Homebrew Cask.
# ==============================================================================

{ pkgs, lib, ... }:

{
  # Only install the Nix package on Linux nodes (macOS uses Homebrew Cask)
  environment.systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.ghostty
  ];

  # Declarative configuration file shared across all platforms
  home-manager.users.jchambers.home.file.".config/ghostty/config.ghostty".text = ''
    # --- Typography & Catppuccin Mocha Visual Styling ---
    font-family = JetBrains Mono
    font-size = 13
    theme = Catppuccin Mocha
    background-opacity = 0.95
    window-padding-x = 8
    window-padding-y = 6
    confirm-close-surface = false
    copy-on-select = clipboard

    # --- Universal Environment Keybinding Pattern (Project 7) ---
    # Clipboard & Font Scaling
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+equal=increase_font_size:1
    keybind = ctrl+shift+minus=decrease_font_size:1
    keybind = ctrl+shift+zero=reset_font_size

    # Native Ghostty Splits (Ctrl+Shift+H/J/K/L so Alt+H/J/K/L passes straight to Zellij)
    keybind = ctrl+shift+d=new_split:right
    keybind = ctrl+shift+s=new_split:down
    keybind = ctrl+shift+x=close_surface
    keybind = ctrl+shift+h=goto_split:left
    keybind = ctrl+shift+j=goto_split:bottom
    keybind = ctrl+shift+k=goto_split:top
    keybind = ctrl+shift+l=goto_split:right

    # Native Ghostty Tabs
    keybind = ctrl+shift+t=new_tab
    keybind = ctrl+shift+w=close_tab
    keybind = ctrl+shift+left=previous_tab
    keybind = ctrl+shift+right=next_tab
  '';
}
