# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/wimlib.nix (Windows WIM Image Optimizer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 5 — 1-to-1 Module for wimlib):
#   Installs 'wimlib' ('wimlib-imagex'), an open-source cross-platform replacement
#   for Windows DISM capable of mounting, debloating, driver-injecting, and
#   re-compressing Windows 11 'install.wim' deployment images directly on Linux.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.wimlib
  ];
}
