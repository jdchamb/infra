{ pkgs, ... }:

{
  programs.hyprland.enable = true;

  # Hyprland usually needs these for a good experience
  services.displayManager.sddm.enable = true;
  environment.systemPackages = with pkgs; [
    waybar           # Status bar
    dunst            # Notifications
    libnotify
    rofi-wayland     # App launcher
    hyprpaper        # Wallpaper
  ];
}
