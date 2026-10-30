# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/hyprland.nix (Hyprland Compositor)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Activates the modern Hyprland Wayland dynamic tiling compositor at the system
#   level alongside SDDM Wayland display manager, Polkit elevation agent, and XDG
#   desktop portals. Injects a cohesive user desktop suite (Waybar status bar,
#   Dunst notification daemon, Rofi launcher, Hyprpaper wallpaper) styled with
#   Catppuccin Mocha accents, governed by the Universal Environment Keybinding
#   Pattern (Project 7).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is Hyprland? Unlike traditional desktop environments (like Windows or
#     macOS) where windows float randomly on top of each other, Hyprland automatically
#     arranges your application windows into a clean, non-overlapping grid (tiling).
#     It runs directly on Wayland (replacing legacy X11) with fluid, GPU-accelerated
#     animations and dual-monitor multi-workspace support.
#   - Polkit ('security.polkit'): In Wayland, applications cannot run as root. When
#     a tool (like GParted or Wireshark) needs administrative access, Polkit prompts
#     you with a graphical password dialog.
#   - XDG Desktop Portals ('xdg.portal'): Under Wayland's strict security architecture,
#     applications cannot spy on your screen or files. Desktop portals provide safe
#     APIs for screen-sharing in web browsers (Google Meet, Discord) and file-picker dialogs.
#   - Universal Keybindings: All window managers across this fleet share the same
#     core shortcuts using the 'Super' (Windows/Command) key:
#       Super + Q = Terminal (Ghostty)
#       Super + E = Web Browser (Firefox)
#       Super + R = Run App Launcher (Rofi)
#       Super + C = Close Window
#       Super + H/J/K/L = Vim-style directional navigation (Left/Down/Up/Right)
#
# HOW TO USE:
#   - Select "Hyprland" at the SDDM login screen.
#   - Press 'Super + R' to search and launch any installed application.
#   - Press 'Super + Q' to open a terminal session.
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System-Level Compositor Activation
  # Installs Hyprland, its wrapper scripts, and required setuid wrappers for DRM/KMS
  # --------------------------------------------------------------------------
  programs.hyprland.enable = true;

  # --------------------------------------------------------------------------
  # 2. Display Manager (SDDM)
  # Uses the modern Wayland backend instead of legacy X11 for the login screen
  # --------------------------------------------------------------------------
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # --------------------------------------------------------------------------
  # 3. Privilege Elevation (Polkit)
  # Enables GUI authentication popups for administrative actions
  # --------------------------------------------------------------------------
  security.polkit.enable = true;

  # --------------------------------------------------------------------------
  # 4. Global Hardware & Wayland System Tools
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    wl-clipboard        # Command-line copy/paste utilities ('wl-copy', 'wl-paste')
    brightnessctl       # Controls laptop screen backlight levels from the CLI/keys
  ];

  # --------------------------------------------------------------------------
  # 5. XDG Desktop Portals (Screen Sharing & File Open Dialogs)
  # --------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    # Dedicated portal handler for Hyprland's wlroots-based protocol extensions
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    # Use desktop-portal-hyprland for all supported portal interfaces
    config.common.default = "*";
  };

  # --------------------------------------------------------------------------
  # 6. User Workspace Configuration (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {

    # User-space desktop accessories
    home.packages = with pkgs; [
      waybar     # Highly customizable GTK status bar
      dunst      # Minimalist, lightweight notification daemon
      rofi       # Keyboard-driven application launcher and menu
      hyprpaper  # Fast, GPU-accelerated Wayland wallpaper daemon
    ];

    # Declarative Waybar Status Bar JSON Configuration
    xdg.configFile."waybar/config".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 32,
        "modules-left": ["hyprland/workspaces", "hyprland/submap"],
        "modules-center": ["clock"],
        "modules-right": ["pulseaudio", "network", "battery", "tray"],
        "clock": { "format": "  {:%H:%M}" }
      }
    '';

    # Hyprland Compositor Runtime Configuration
    xdg.configFile."hypr/hyprland.conf".text = ''
      # Automatically configure monitor at highest supported refresh rate
      monitor=,highrr,auto,1

      # Launch desktop components on session startup
      exec-once = waybar
      exec-once = dunst
      exec-once = hyprpaper

      # Input devices
      input {
          kb_layout = us
          numlock_by_default = true
          follow_mouse = 1
      }

      # Window layout and borders
      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(b4befeee)
          col.inactive_border = rgba(11111bfe)
          layout = dwindle
      }

      # Rounded window corners
      decoration {
          rounding = 8
      }

      # --- Universal Environment Keybinding Pattern (Project 7) ---
      $mainMod = SUPER

      # Core Application Shortcuts
      bind = $mainMod, Q, exec, ghostty          # Terminal emulator
      bind = $mainMod, E, exec, firefox          # Web browser
      bind = $mainMod, R, exec, rofi -show drun  # Application launcher
      bind = $mainMod, C, killactive,            # Close active window
      bind = $mainMod, M, exit,                  # Exit Hyprland session

      # Directional Window Focus (Vim keys: H=Left, J=Down, K=Up, L=Right)
      bind = $mainMod, H, movefocus, l
      bind = $mainMod, J, movefocus, d
      bind = $mainMod, K, movefocus, u
      bind = $mainMod, L, movefocus, r

      # Directional Window Movement (Super + Shift + Vim keys)
      bind = $mainMod SHIFT, H, movewindow, l
      bind = $mainMod SHIFT, J, movewindow, d
      bind = $mainMod SHIFT, K, movewindow, u
      bind = $mainMod SHIFT, L, movewindow, r
    '';
  };
}
