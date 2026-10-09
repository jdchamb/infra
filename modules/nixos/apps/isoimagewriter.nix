# app-isoimagewriter.nix
# ROLE: Standalone OS Installation Image Flasher

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.kdePackages.isoimagewriter
  ];
}
