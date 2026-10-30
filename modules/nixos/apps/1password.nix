# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/1password.nix (1Password Desktop & CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 6 — 1-to-1 Module for 1Password):
#   Enables the 1Password CLI ('op') and Desktop GUI with Polkit system
#   authentication integration for 'jchambers'.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Unlike a simple standalone binary, 1Password on Linux needs deep OS
#   integration (Polkit policies and setgid wrappers) so you can unlock your
#   vault using your Linux system password or hardware biometric/FIDO2 prompt,
#   and so the 1Password browser extension in Firefox/Chrome can securely talk
#   to the desktop app. Using NixOS's built-in 'programs._1password-gui' module
#   wires up those Polkit rules automatically for 'jchambers'.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Enable the 1Password CLI ('op') with proper group/binary permissions
  programs._1password.enable = true;

  # 2. Enable the 1Password Desktop GUI and authorize 'jchambers' via Polkit
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "jchambers" ];
  };
}
