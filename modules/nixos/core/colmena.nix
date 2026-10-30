# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/colmena.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for Colmena):
#   Installs 'colmena', a parallel NixOS Hive deployment tool ideal for pushing
#   synchronized system updates across the 5-node HP ProBook validation lab.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.colmena
  ];
}
