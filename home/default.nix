{ config, pkgs, inputs, ... }:

{
  home = {
    username = "jchambers";
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/jchambers" else "/home/jchambers";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./programs/zsh.nix
    ./programs/starship.nix
  ];
}
