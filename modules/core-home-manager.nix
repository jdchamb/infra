# File: modules/core-home-manager.nix
{ config, pkgs, inputs, ... }:

{
  # Explicitly declare user profile specifications
  home = {
    username = "jchambers"; #
    homeDirectory = "/home/jchambers"; #
    stateVersion = "24.11"; #
  };

  # Let Home Manager manage its own software profile path wrapper
  programs.home-manager.enable = true; #

  # Import user-space shell components
  imports = [
    "${inputs.self}/modules/core-zsh.nix" #
    "${inputs.self}/modules/core-starship.nix" #
  ];
}
