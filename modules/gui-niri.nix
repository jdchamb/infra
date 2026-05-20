{ pkgs, ... }:

{
  # 1. Enable Core Niri Window Manager
  programs.niri.enable = true;

  # 2. Display Manager Configuration
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  # 3. Essential Security/Privilege Escalation
  security.polkit.enable = true;

  # 4. Mandatory Environment Packages & Noctalia Backends
  environment.systemPackages = with pkgs; [
    # The Shell Environment
    noctalia-shell      # Status bar, notifications, dynamic themes, widgets, OSD
    xwayland-satellite  # Handles XWayland app scaling and cursor wrapping under Niri

    # Critical System Backends
    wl-clipboard        # Wayland clipboard engine
    brightnessctl       # Controls monitor/backlight steps seamlessly for Noctalia
    imagemagick         # Used by Noctalia to generate automated color palettes from your wallpaper
  ];

  # 5. Native D-Bus Portal Integrations
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };

  # Enable user space targets so systemd can trigger background daemon panels
  systemd.user.targets.tray.enable = true;
}
