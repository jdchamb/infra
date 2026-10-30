# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/1password.nix (1Password Desktop & CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 — 1-to-1 Module for 1Password):
#   Enables the 1Password CLI ('op') and Desktop GUI with Polkit system
#   authentication integration for 'jchambers'.
# ==============================================================================

{ config, pkgs, ... }:

{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "jchambers" ];
  };
}
