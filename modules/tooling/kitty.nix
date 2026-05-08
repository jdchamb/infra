{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.kitty ];

  # Global config for Kitty (Backup)
  environment.etc."xdg/kitty/kitty.conf".text = ''
    background_opacity 0.95
    confirm_os_window_close 0
    font_family JetBrains Mono
  '';
}
