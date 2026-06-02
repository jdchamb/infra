# File: modules/core-home-manager.nix
{ config, pkgs, inputs, ... }:

{
  # Let Home Manager install and manage itself inside the user environment
  programs.home-manager.enable = true;

  # Define Target User Space Parameters
  home.username = "jchambers";
  home.homeDirectory = "/home/jchambers";
  home.stateVersion = "24.11";

  # Pull in User-Space Module Bricks
  imports = [
    "${inputs.self}/modules/core-zsh.nix"
    "${inputs.self}/modules/core-starship.nix"
  ];
}
