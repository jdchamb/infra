{ pkgs, ... }:

{
  # 1. System-Level Compositor Activation
  programs.hyprland.enable = true;

  # 2. Display Manager Backend Hook
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # 3. Ambient Privileged Security Layer
  security.polkit.enable = true;

  # 4. Global Hardware/Session Utilities
  environment.systemPackages = with pkgs; [
    wl-clipboard        # Wayland clipboard management engine
    brightnessctl       # Native display backlight controller steps
  ];

  # 5. Native D-Bus Portal Matrix
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
    config.common.default = "*";
  };

  # 6. Unified Home Manager Workspace Configuration
  home-manager.users.jchambers = { ... }: {

    # Session-specific packages
    home.packages = with pkgs; [
      waybar
      dunst
      rofi
      hyprpaper
    ];

    # Consistent Waybar Layout & Styling Schema
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

    # Direct Compositor Configuration File Bindings
    xdg.configFile."hypr/hyprland.conf".text = ''
      # --- Hyprland Core Initialization Matrix ---
      monitor=,highrr,auto,1

      exec-once = waybar
      exec-once = dunst
      exec-once = hyprpaper

      input {
          kb_layout = us
          follow_mouse = 1
      }

      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(b4befeee)
          col.inactive_border = rgba(11111bfe)
          layout = dwindle
      }

      decoration {
          rounding = 8
      }

      $mainMod = SUPER
      bind = $mainMod, Q, exec, ghostty
      bind = $mainMod, E, exec, firefox
      bind = $mainMod, R, exec, rofi -show drun
      bind = $mainMod, C, killactive,
      bind = $mainMod, M, exit,
    '';
  };
}
