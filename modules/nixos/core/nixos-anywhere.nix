# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/nixos-anywhere.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for nixos-anywhere):
#   Installs 'nixos-anywhere' and provides the 'remote-nixos-anywhere' wrapper
#   script to partition (via Disko) and install NixOS onto any bare-metal or VM
#   target over SSH in a single unattended pass.
# ==============================================================================

{ config, lib, pkgs, ... }:

let
  remoteNixosAnywhere = pkgs.writeShellScriptBin "remote-nixos-anywhere" ''
    set -euo pipefail
    HOST_FLAKE="''${1:-}"
    TARGET_IP="''${2:-}"

    if [ -z "$HOST_FLAKE" ] || [ -z "$TARGET_IP" ]; then
      echo "Usage: remote-nixos-anywhere <flake-host> <root@ip-or-hostname>"
      echo "Example: remote-nixos-anywhere lab-pb01 root@10.14.5.101"
      exit 1
    fi

    echo "==> Executing zero-touch network installation of #$HOST_FLAKE onto $TARGET_IP..."
    ${pkgs.nixos-anywhere}/bin/nixos-anywhere \
      --flake "$HOME/src/infra#$HOST_FLAKE" \
      "$TARGET_IP"
  '';
in
{
  environment.systemPackages = [
    pkgs.nixos-anywhere
    remoteNixosAnywhere
  ];

  nix.distributedBuilds = lib.mkDefault true;
  nix.settings.builders-use-substitutes = true;
}
