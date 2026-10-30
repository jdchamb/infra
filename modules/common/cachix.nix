# ==============================================================================
# COMMON MODULE: modules/common/cachix.nix (Binary Cache Substituters)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Configures the Nix daemon to pull pre-compiled store paths ("substitutes")
#   from both the official NixOS binary cache and the 'nix-community' Cachix
#   server before falling back to compiling from source code locally.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In Nix, every package is mathematically defined by its source code and build
#   inputs. Without a "binary cache" (called a substituter), your computer would
#   have to compile huge programs (like compilers, browsers, or community packages)
#   from scratch, taking hours.
#   By listing 'substituters' and their cryptographic 'trusted-public-keys':
#     1. Nix calculates the hash of the package it needs.
#     2. Nix asks 'cache.nixos.org' and 'nix-community.cachix.org' if they
#        already compiled that exact hash.
#     3. If found, Nix downloads the pre-built binary and verifies its digital
#        signature against 'trusted-public-keys' so nobody can tamper with it.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Install the 'cachix' CLI tool globally so an administrator can easily
  #    push or pull from additional custom binary caches when needed.
  environment.systemPackages = [ pkgs.cachix ];

  # 2. Declare Binary Cache Endpoints and Ed25519 Public Verification Keys
  nix.settings = {
    # URLs of remote servers that store pre-compiled Nix store paths (/nix/store/...)
    substituters = [
      "https://cache.nixos.org"          # Official NixOS Hydra build farm cache
      "https://nix-community.cachix.org" # Community cache (Home Manager, Disko, etc.)
    ];

    # Cryptographic Ed25519 public keys used to verify that downloaded binaries
    # genuinely came from the caches above and were not modified in transit.
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
