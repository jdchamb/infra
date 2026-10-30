# ==============================================================================
# NIXOS DESKTOP MODULE: modules/nixos/desktop/niri.nix (Niri Scrollable Tiling)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the innovative Niri scrollable-tiling Wayland compositor paired with
#   Noctalia Shell and XWayland-Satellite. Establishes the Universal Environment
#   Keybinding Pattern (Project 7): uses Super+H/J/K/L for compositor ribbon and
#   column navigation, while cleanly reserving Alt+H/J/K/L for Zellij multiplexer
#   panes and Ctrl+Shift+H/J/K/L for Ghostty terminal splits.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - What is Scrollable Tiling? Traditional tiling compositors (like i3 or bspwm)
#     divide your monitor into smaller and smaller slices as you open windows.
#     On a laptop screen, after 3 or 4 windows, everything becomes too small to read!
#     Niri takes a completely different approach inspired by PaperWM: it arranges
#     your windows in an infinite horizontal ribbon. Each window stays at a comfortable,
#     readable size (e.g. 50% or 100% width), and you scroll smoothly left and right
#     across the strip using keyboard shortcuts or touchpad gestures.
#   - KDL Configuration Language: Niri's config ('config.kdl') uses KDL, an elegant
#     document language designed for readability with node-based hierarchy.
#   - Noctalia Shell: A unified desktop shell providing the top bar, control center,
#     and notification tray.
#   - XWayland Satellite ('xwayland-satellite'): Runs legacy X11 applications
#     inside an isolated XWayland server instance outside the main compositor loop,
#     preventing crashes in old X11 apps from bringing down your entire desktop.
#   - Keybinding Layering (Project 7):
#       Compositor Layer: Super + H / J / K / L (moves columns left/right, windows up/down)
#       Multiplexer Layer: Alt + H / J / K / L (navigates Zellij panes inside terminals)
#       Editor/Terminal Layer: Ctrl + Shift + H / J / K / L (navigates Ghostty splits)
#     This three-tier separation completely prevents keybinding collisions!
#
# HOW TO USE:
#   - Select "Niri" at the SDDM login screen.
#   - Press 'Super + Q' to open a terminal; press 'Super + E' to open Firefox.
#   - Scroll the horizontal ribbon: 'Super + H' (scroll left) / 'Super + L' (scroll right).
#   - Reorder columns: 'Super + Shift + H' / 'Super + Shift + L'.
# ==============================================================================

{ pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. System-Level Compositor Activation
  # --------------------------------------------------------------------------
  programs.niri.enable = true;

  # --------------------------------------------------------------------------
  # 2. Display Manager (SDDM Wayland Session)
  # --------------------------------------------------------------------------
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # --------------------------------------------------------------------------
  # 3. Privilege Elevation (Polkit)
  # --------------------------------------------------------------------------
  security.polkit.enable = true;

  # --------------------------------------------------------------------------
  # 4. Global Packages & Noctalia Shell Integration
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    noctalia            # Status bar, control center, and notification platform (v5)
    xwayland-satellite  # Out-of-process XWayland server wrapper
    wl-clipboard        # Wayland command-line clipboard tools ('wl-copy', 'wl-paste')
    brightnessctl       # Display backlight control utility
    imagemagick         # Image processing library used for dynamic theming
  ];

  # --------------------------------------------------------------------------
  # 5. XDG Desktop Portals
  # Uses the GNOME portal implementation recommended for Niri
  # --------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # Systemd user session targets
  systemd.user.targets.tray.enable = true;

  # --------------------------------------------------------------------------
  # 6. User Workspace Configuration (Home Manager for 'jchambers')
  # --------------------------------------------------------------------------
  home-manager.users.jchambers = { ... }: {

    # Declarative Niri KDL Configuration File
    xdg.configFile."niri/config.kdl".text = ''
      // --- Niri Scroll-Tiling Core Configuration ---
      input {
          keyboard {
              xkb {
                  layout "us"
              }
              numlock
          }
          touchpad {
              tap
          }
      }

      // Built-in laptop display scaling
      output "eDP-1" {
          scale 1.0
      }

      // Strip layout: 8px gaps, 50% screen width per column
      layout {
          gaps 8
          center-focused-column "never"
          default-column-width { proportion 0.5; }
          focus-ring {
              width 2
              active-color "#b4befe"
              inactive-color "#11111b"
          }
      }

      // Autostart shell and legacy X11 compatibility bridge
      spawn-at-startup "noctalia"
      spawn-at-startup "xwayland-satellite"

      // --- Universal Environment Keybinding Pattern (Project 7) ---
      binds {
          // Application Launchers
          Mod+Q { spawn "ghostty"; }
          Mod+E { spawn "firefox"; }
          Mod+R { spawn "rofi" "-show" "drun"; }
          Mod+C { close-window; }
          Mod+M { quit; }

          // Directional Ribbon & Column Focus (Vim keys)
          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          // Move Columns Along the Ribbon
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
      }
    '';
  };
}
