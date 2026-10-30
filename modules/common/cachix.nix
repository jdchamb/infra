# ==============================================================================
# COMMON MODULE: modules/common/cachix.nix (Binary Cache Substituters)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the Nix daemon to pull pre-compiled store paths from both the
#   official NixOS cache and the 'nix-community' Cachix pool before compiling
#   from source, dramatically accelerating builds across workstations and ISOs.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Install the Cachix CLI utility for managing custom binary caches
  environment.systemPackages = [ pkgs.cachix ];

  # 2. Declare Binary Cache Endpoints and Ed25519 Public Verification Keys
  nix.settings = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
