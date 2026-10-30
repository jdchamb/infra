# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/global.nix (Unified Global Baseline)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 19):
#   This module acts as the single foundational import for managed NixOS machines
#   across the fleet. Importing 'global.nix' guarantees a consistent baseline:
#     - SOPS cryptographic secret schema registration
#     - Timezone, locale, Nix Flakes settings, and automatic store GC
#     - NetworkManager, firewall defaults, and diagnostic tools
#     - Primary administrative user ('jchambers') and Zsh shell registration
#     - Binary cache substituters (cache.nixos.org & nix-community)
#     - Base typography (JetBrains Mono & Fira Code Nerd Fonts)
#     - Hardware diagnostic & filesystem utilities
#     - SOPS/Age CLI inspection binaries
# ==============================================================================

{ inputs, ... }:

{
  imports = [
    # 1. Upstream Third-Party Schema Registrations
    inputs.sops-nix.nixosModules.sops

    # 2. Common Fleet Foundations
    "${inputs.self}/modules/common/fonts.nix"
    "${inputs.self}/modules/common/cachix.nix"
    "${inputs.self}/modules/common/sops-tools.nix"

    # 3. Universal NixOS Core Bricks
    "${inputs.self}/modules/nixos/core/system.nix"
    "${inputs.self}/modules/nixos/core/network.nix"
    "${inputs.self}/modules/nixos/core/user.nix"
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"
  ];
}
