# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/remmina.nix (Remmina Remote Desktop)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Remmina):
#   Installs Remmina for managing remote Windows Server (PDQ, WDS, AD), macOS,
#   and VNC endpoints across the USD 308 network and on the recovery ISO.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.remmina
  ];
}
