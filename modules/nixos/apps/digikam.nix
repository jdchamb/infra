# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/digikam.nix (DigiKam Photo Management)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for DigiKam):
#   Installs DigiKam alongside 'exiftool' and 'ffmpeg' for organizing local
#   photography libraries, batch-tagging metadata, and inspecting RAW media.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    digikam
    exiftool
    ffmpeg
  ];
}
