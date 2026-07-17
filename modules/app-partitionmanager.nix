# app-partitionmanager.nix
# ROLE: Standalone Disk Partitioning Utility

{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.kdePackages.partitionmanager
  ];
}
