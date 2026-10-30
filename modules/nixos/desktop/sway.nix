# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/sway.nix (Sway Wayland Compositor)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides a lightweight, ultra-stable i3-compatible Wayland tiling compositor
#   environment integrated with Waybar, Dunst, and Rofi. Shares the identical
#   Super+Q/E/R/C/M application shortcuts and Super+H/J/K/L navigation keybinding
#   topology used across Hyprland and Niri (Universal Environment Pattern).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is Sway? For over a decade, 'i3' was the gold standard for keyboard-driven
#     tiling window managers on Linux, but i3 is tied to legacy X11. Sway is a drop-in
#     replacement for i3 built from the ground up for modern Wayland. It uses the
#     exact same mental model (manual tree-based tiling) and configuration syntax,
#     while gaining Wayland's smooth tear-free rendering and security sandboxing.
#   - Why keep Sway alongside Hyprland and Niri? Sway is known for extreme rock-solid
#     stability and tiny memory footprint. If an experimental feature or GPU driver
#     update ever glitches in newer compositors, Sway is the dependable fallback.
#   - Portal ('xdg-desktop-portal-wlr'): Provides wlroots-native screen recording
#     and window capture protocols for OBS Studio and web browsers.
#
# HOW TO USE:
#   - Select "Sway" at the SDDM login screen.
#   - Press 'Super + Q' to open a terminal (Ghostty).
#   - Press 'Super + R' to launch the Rofi application runner.
#   - Navigate between split windows: 'Super + H / J / K / L'.
#   - Split window horizontally vs vertically: i3/Sway manual tiling rules apply.
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System-Level Compositor Activation
  # --------------------------------------------------------------------------
  programs.sway.enable = true;

  # --------------------------------------------------------------------------
  # 2. Display Manager Backend (SDDM Wayland)
  # --------------------------------------------------------------------------
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # --------------------------------------------------------------------------
  # 3. Privilege Elevation Layer (Polkit)
  # --------------------------------------------------------------------------
  security.polkit.enable = true;

  # --------------------------------------------------------------------------
  # 4. Global System Utilities
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    wl-clipboard        # Wayland command-line clipboard engine ('wl-copy', 'wl-paste')
    brightnessctl       # Display brightness controller utility
  ];

  # --------------------------------------------------------------------------
  # 5. XDG Desktop Portals
  # Uses the wlroots portal implementation for screen casting and capture
  # --------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  # --------------------------------------------------------------------------
  # 6. User Workspace Configuration (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {

    # User-space desktop accessories
    home.packages = with pkgs; [
      waybar  # Highly configurable GTK status bar
      dunst   # Lightweight notification daemon
      rofi    # Keyboard application launcher
    ];

    # Declarative Waybar Status Bar JSON Configuration
    xdg.configFile."waybar/config".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 32,
        "modules-left": ["sway/workspaces", "sway/mode"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "network", "battery", "tray"],
        "clock": { "format": "  {:%H:%M}" }
      }
    '';

    # Sway Compositor Configuration File
    xdg.configFile."sway/config".text = ''
      # --- Sway Core Configuration ---
      # Mod4 corresponds to the Super / Windows / Command key
      set $mod Mod4

      # Vim-style directional navigation aliases
      set $left h
      set $down j
      set $up k
      set $right l

      # Default terminal and launcher
      set $term ghostty
      set $menu rofi -show drun

      # Solid background color for clean, distraction-free aesthetic
      output * bg #11111b solid

      # Start status bar and notification daemon on session launch
      exec waybar
      exec dunst

      # Configure keyboard layout and enforce NumLock ON
      input * {
          xkb_layout "us"
          xkb_numlock enabled
      }

      # Window margins and borders
      gaps inner 5
      gaps outer 10
      default_border pixel 2

      # Window border colors (Catppuccin Lavender accent)
      client.focused #b4befe #11111b #b4befe #b4befe

      # --- Universal Application Shortcuts ---
      bindsym $mod+q exec $term         # Terminal emulator
      bindsym $mod+e exec firefox       # Web browser
      bindsym $mod+r exec $menu         # App launcher
      bindsym $mod+c kill               # Close focused window
      bindsym $mod+m exit               # Exit Sway session

      # --- Directional Window Focus (Super + H/J/K/L) ---
      bindsym $mod+$left focus left
      bindsym $mod+$down focus down
      bindsym $mod+$up focus up
      bindsym $mod+$right focus right

      # --- Directional Window Movement (Super + Shift + H/J/K/L) ---
      bindsym $mod+Shift+$left move left
      bindsym $mod+Shift+$down move down
      bindsym $mod+Shift+$up move up
      bindsym $mod+Shift+$right move right
    '';
  };
}
