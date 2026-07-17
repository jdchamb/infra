{ pkgs, ... }:

{
  # 1. System-Level Compositor Activation
  programs.sway.enable = true;

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
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };

  # 6. Unified Home Manager Workspace Configuration
  home-manager.users.jchambers = { ... }: {

    # Session-specific packages
    home.packages = with pkgs; [
      waybar
      dunst
      rofi-wayland
    ];

    # Consistent Waybar Layout & Styling Schema
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

    # Direct Compositor Configuration File Bindings
    xdg.configFile."sway/config".text = ''
      # --- Sway Core Initialization Matrix ---
      set $mod Mod4
      set $left h
      set $down j
      set $up k
      set $right l

      set $term ghostty
      set $menu rofi -show drun

      output * bg #11111b solid

      exec waybar
      exec dunst

      input * {
          xkb_layout "us"
      }

      gaps inner 5
      gaps outer 10
      default_border pixel 2

      client.focused #b4befe #11111b #b4befe #b4befe

      bindsym $mod+q exec $term
      bindsym $mod+e exec firefox
      bindsym $mod+r exec $menu
      bindsym $mod+c kill
      bindsym $mod+m exit
    '';
  };
}
