# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/colmena.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for Colmena):
#   Installs 'colmena', a parallel NixOS Hive deployment tool ideal for pushing
#   synchronized system updates across the 5-node HP ProBook validation lab.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Running 'nixos-rebuild switch' one laptop at a time across 5 lab machines
#   ('lab-pb01' through 'lab-pb05') is slow and repetitive. 'Colmena' lets you
#   build all 5 machine profiles on your powerful workstation once and push the
#   resulting '/nix/store' paths to all 5 laptops simultaneously over SSH in
#   parallel.
# ==============================================================================

{ pkgs, ... }:

{
  # Install the 'colmena' multi-host deployment CLI onto the workstation PATH
  environment.systemPackages = [
    pkgs.colmena
  ];
}
