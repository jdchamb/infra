# modules/core-home-manager.nix
{ config, pkgs, inputs, ... }:

{
  home = {
    username = "jchambers";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/jchambers" else "/home/jchambers";

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  imports = [
    "${inputs.self}/modules/core-zsh.nix"
    "${inputs.self}/modules/core-starship.nix"
  ];
}
