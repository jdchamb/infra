{ pkgs, ... }:

{
  # 1. System-Level Compositor Activation
  programs.niri.enable = true;

  # 2. Display Manager Backend Hook
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # 3. Ambient Privileged Security Layer
  security.polkit.enable = true;

  # 4. Global Hardware/Session Utilities & Noctalia Ecosystem
  environment.systemPackages = with pkgs; [
    noctalia-shell      # Component-unified status bar, notification, styling platform
    xwayland-satellite  # Seamless XWayland scaling container application
    wl-clipboard        # Wayland clipboard management engine
    brightnessctl       # Native display backlight controller steps
    imagemagick         # Live dynamic color translation runner
  ];

  # 5. Native D-Bus Portal Matrix
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # Systemd user targets mapping layer
  systemd.user.targets.tray.enable = true;

  # 6. Unified Home Manager Workspace Configuration
  home-manager.users.jchambers = { ... }: {

    # Direct Scroll-Based Compositor Configuration File Bindings
    xdg.configFile."niri/config.kdl".text = ''
      // --- Niri Scroll-Tiling Core Initialization Matrix ---
      input {
          keyboard {
              xkb {
                  layout "us"
              }
          }
          touchpad {
              tap
          }
      }

      output "eDP-1" {
          scale 1.0
      }

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

      spawn-at-startup "noctalia-shell"
      spawn-at-startup "xwayland-satellite"

      binds {
          Mod+Q { spawn "ghostty"; }
          Mod+E { spawn "firefox"; }
          Mod+R { spawn "rofi" "-show" "drun"; }
          Mod+C { close-window; }
          Mod+M { quit; }

          Mod+H     { focus-column-left; }
          Mod+J     { focus-window-down; }
          Mod+K     { focus-window-up; }
          Mod+L     { focus-column-right; }

          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
      }
    '';
  };
}
