# ==============================================================================
# NIXOS CORE MODULE: modules/nixos/core/deploy-rs.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 2 — 1-to-1 Module for deploy-rs):
#   Installs Serokell's 'deploy-rs' multi-node atomic deployment tool with
#   automatic magic-rollback protection if a network change severs SSH connectivity.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   The biggest risk when updating a headless server or remote firewall over SSH
#   is accidentally misconfiguring a network interface or firewall rule and
#   locking yourself out permanently.
#   'deploy-rs' solves this with "Magic Rollback": after activating the new
#   NixOS generation on the remote machine, 'deploy-rs' waits for your workstation
#   to confirm it can still talk to the server over SSH. If the connection drops,
#   a background timer on the server automatically reverts to the previous
#   working NixOS configuration within 30 seconds!
# ==============================================================================

{ pkgs, ... }:

{
  # Install 'deploy-rs' ('deploy' binary) globally on the administering workstation
  environment.systemPackages = [
    pkgs.deploy-rs
  ];
}
