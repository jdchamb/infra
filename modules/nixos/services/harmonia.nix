# ==============================================================================
# NIXOS SERVICE MODULE: modules/nixos/services/harmonia.nix (Nix Binary Cache)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 24 — 1-to-1 Module for Harmonia):
#   Configures 'services.harmonia', a high-performance Rust Nix binary cache
#   daemon that serves compiled '/nix/store' paths over HTTP (port 5000).
#   Allows you to host a local/community NixOS binary cache mirror so lab nodes
#   and community peers don't burden upstream cache.nixos.org bandwidth.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # 1. Enable Harmonia Binary Cache Daemon on Port 5000
  services.harmonia = {
    enable = true;
    settings = {
      bind = "[::]:5000";
      priority = 30;
    };
  };

  networking.firewall.allowedTCPPorts = [ 5000 ];

  # 2. Helper CLI for Generating Ed25519 Binary Cache Signing Keys
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "init-harmonia-keys" ''
      set -euo pipefail
      KEY_DIR="/var/lib/secrets/harmonia"
      sudo mkdir -p "$KEY_DIR"
      if [ ! -f "$KEY_DIR/cache.sec" ]; then
        sudo nix-store --generate-binary-cache-key "${config.networking.hostName}-cache-1" \
          "$KEY_DIR/cache.sec" "$KEY_DIR/cache.pub"
        sudo chmod 0600 "$KEY_DIR/cache.sec"
        echo "==> Generated Nix Binary Cache keypair in $KEY_DIR"
        cat "$KEY_DIR/cache.pub"
      else
        echo "==> Cache keypair already exists at $KEY_DIR:"
        cat "$KEY_DIR/cache.pub"
      fi
    '')
  ];
}
