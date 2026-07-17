# app-filelight.nix
# ROLE: Standalone Graphical Storage Analyzer

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.kdePackages.filelight
  ];
}
