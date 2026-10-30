# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/isoimagewriter.nix (USB ISO Flasher)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 1 — 1-to-1 Module for ISO Image Writer):
#   Installs KDE 'isoimagewriter' for writing compiled NixOS bootstrap/recovery
#   ISOs and Windows 11 deployment images safely onto physical USB media.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.kdePackages.isoimagewriter
  ];
}
