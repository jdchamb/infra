{ config, pkgs, ... }:

{
  # Modern Nixpkgs structure targets the exact nerd font package directly
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
