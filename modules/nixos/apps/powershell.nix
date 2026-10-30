# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/powershell.nix (PowerShell Core CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 1, 9, 14, 16 — 1-to-1 Module for PowerShell):
#   Installs Microsoft PowerShell Core ('pwsh') on NixOS workstations to author,
#   lint, and test USD 308 PDQ Deploy and Windows 11 automation scripts locally.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.powershell
  ];
}
