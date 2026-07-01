{ config, pkgs, ... }:

{
  # Enforces the flattened, modern unstable channel naming scheme using underscores
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains_mono
  ];
}
