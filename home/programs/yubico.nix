# ==============================================================================
# USER-SPACE SECURITY KEYS: home/programs/yubico.nix
# ==============================================================================
# Declaratively provisions the user's FIDO2/U2F key mapping for pam_u2f.
# This file is version-controlled in the repository and symlinked to
# ~/.config/Yubico/u2f_keys across all fleet workstations (macOS & NixOS).
#
# ORIGIN CONVENTION:
#   pam://local (standardized across the fleet)
#
# ENROLLMENT:
#   See docs/hardware_security_keys_runbook.md
# ==============================================================================

{ config, pkgs, lib, ... }:

{
  xdg.configFile."Yubico/u2f_keys".source = ./u2f_keys;
}
