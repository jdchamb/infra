{ config, pkgs, inputs, ... }:

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

{
  home.username = "jchambers";
  home.homeDirectory = "/home/jchambers";
  home.stateVersion = "24.11"; # Match your system version

  imports = [
    "${inputs.self}/modules/core-zsh.nix"
    "${inputs.self}/modules/core-starship.nix"
  ];


}
