# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/glabels.nix (Asset Label & Barcode Designer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 19, 21, 22 — 1-to-1 Module for gLabels):
#   Installs 'glabels-qt' for designing and CSV mail-merging Snipe-IT barcode and
#   QR code asset labels for DYMO and sheet label printers.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When labeling dozens of ClearTouch boards, Chromebooks, or HP laptops for
#   USD 308 buildings (Grandview, HVS, HHS), printing labels one by one is too
#   slow. 'glabels-qt' takes a CSV spreadsheet exported from Snipe-IT and
#   automatically generates a batch of formatted barcode/asset stickers ready
#   to send straight to our DYMO LabelWriter ('modules/nixos/apps/dymo.nix').
# ==============================================================================

{ pkgs, ... }:

{
  # Install the Qt edition of gLabels label/barcode designer
  environment.systemPackages = [
    pkgs.glabels-qt
  ];
}
