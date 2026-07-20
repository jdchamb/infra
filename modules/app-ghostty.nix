{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.ghostty ];

  home-manager.users.jchambers.home.file.".config/ghostty/config.ghostty".text = ''
    font-family = JetBrains Mono
    font-size = 14
    theme = Catppuccin Mocha
    background-opacity = 0.95
  '';
}
