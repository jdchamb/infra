# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/digikam.nix (DigiKam Photo Management)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for DigiKam):
#   Installs DigiKam alongside 'exiftool' and 'ffmpeg' for organizing local
#   photography libraries, batch-tagging metadata, and inspecting RAW media.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   DigiKam is an open-source digital asset manager for large photo libraries.
#   It relies on 'exiftool' to read/write camera EXIF tags (dates, GPS, lens info)
#   and 'ffmpeg' to generate thumbnails and play video clips inside the catalog,
#   so we bundle all three together in this module.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    digikam  # KDE professional photo management and facial/tag cataloging suite
    exiftool # CLI & backend library for reading/editing image EXIF/IPTC metadata
    ffmpeg   # Video/audio transcoding engine used by DigiKam for video previews
  ];
}
