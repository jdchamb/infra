{ config, pkgs, ... }:

{
  home.username = "jchambers";
  home.homeDirectory = "/home/jchambers";
  home.stateVersion = "24.11"; # Match your system version

  imports = [
    ./zsh.nix
    ./starship.nix
  ];

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}
