# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/normcap.nix (NormCap Screen OCR)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for NormCap):
#   Installs NormCap, an OCR-powered screen-capture tool that extracts text
#   (such as MAC addresses, serial numbers, or error codes from remote VNC/RDP
#   windows) directly into the system clipboard.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.normcap
  ];
}
