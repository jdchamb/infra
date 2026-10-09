# app-kdf.nix
# ROLE: Standalone Disk Usage Space Monitor

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.kdePackages.kdf
  ];
}
