# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/global.nix (Unified Global Baseline)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 19 — Unified Fleet Foundation):
#   This module acts as the single composite baseline import for all managed NixOS
#   machines across the fleet. Instead of manually copying dozens of imports into
#   every host's configuration, importing 'global.nix' guarantees that every host
#   reliably inherits:
#     - Upstream sops-nix cryptographic secret schema options.
#     - Common fleet typography (JetBrains Mono & Fira Code Nerd Fonts).
#     - Binary cache substituters (cache.nixos.org & nix-community Cachix).
#     - SOPS and Age encryption CLI utilities.
#     - System settings (timezone, UTF-8 locale, Flakes, weekly garbage collection).
#     - NetworkManager and default-deny firewall policies.
#     - Primary administrative user ('jchambers') and group privileges.
#     - Hardware diagnostic and disk maintenance tools ('hw-utils.nix').
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   In software engineering, the DRY principle ("Don't Repeat Yourself") prevents
#   configuration drift. In a multi-machine NixOS fleet (laptops, desktops, servers,
#   installer ISOs), you want every computer to speak the same language, have the
#   same admin user, and connect to the same binary caches.
#   'global.nix' is the architectural "bundle" that brings together the fundamental
#   operating system layers into a single declarative import.
#
# HOW TO USE:
#   - In any NixOS host file (e.g. 'hosts/nixos/308-222242/default.nix'), include:
#       imports = [
#         ../../modules/nixos/core/global.nix
#         ...
#       ];
#   - That host now has full fleet baseline functionality without redundant lines.
# ==============================================================================

{ inputs, ... }:

{
  imports = [
    # --------------------------------------------------------------------------
    # 1. Upstream Third-Party Module Schemas
    # Adds the 'sops' options hierarchy to the NixOS configuration evaluator.
    # --------------------------------------------------------------------------
    inputs.sops-nix.nixosModules.sops

    # --------------------------------------------------------------------------
    # 2. Common Fleet Foundations (Shared across NixOS and nix-darwin)
    # --------------------------------------------------------------------------
    "${inputs.self}/modules/common/fonts.nix"       # Developer monospace Nerd Fonts
    "${inputs.self}/modules/common/cachix.nix"      # Fast pre-built binary substituters
    "${inputs.self}/modules/common/sops-tools.nix"  # sops and age CLI packages

    # --------------------------------------------------------------------------
    # 3. Universal NixOS Core Modules
    # --------------------------------------------------------------------------
    "${inputs.self}/modules/nixos/core/system.nix"        # Timezone, locale, flakes, GC
    "${inputs.self}/modules/nixos/core/network.nix"       # NetworkManager and firewall
    "${inputs.self}/modules/nixos/core/user.nix"          # 'jchambers' account & wheel
    "${inputs.self}/modules/nixos/hardware/hw-utils.nix"  # smartmontools, pciutils, usbutils
  ];
}
