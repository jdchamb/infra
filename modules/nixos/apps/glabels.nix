# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/glabels.nix (Asset Label & Barcode Designer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 19, 21, 22 — 1-to-1 Module for gLabels):
#   Installs 'glabels-qt' for designing and CSV mail-merging Snipe-IT barcode and
#   QR code asset labels for DYMO and sheet label printers.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.glabels-qt
  ];
}
