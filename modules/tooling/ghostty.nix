{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ghostty ];

  # This places the config file exactly where Ghostty expects it
  home-manager.users.jchambers.home.file.".config/ghostty/config".text = ''
    font-family = JetBrains Mono
    font-size = 14
    theme = catppuccin-mocha
    background-opacity = 0.95
  '';
}
