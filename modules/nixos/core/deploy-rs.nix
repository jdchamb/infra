# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/deploy-rs.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for deploy-rs):
#   Installs Serokell's 'deploy-rs' multi-node atomic deployment tool with
#   automatic magic-rollback protection if a network change severs SSH connectivity.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.deploy-rs
  ];
}
