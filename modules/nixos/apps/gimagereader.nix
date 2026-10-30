# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/gimagereader.nix (Graphical OCR Parser)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 2 — 1-to-1 Module for gImageReader):
#   Installs the GTK front-end to Tesseract OCR ('gimagereader') for extracting
#   structured text, serial numbers, and tables from scanned PDFs and equipment
#   invoices.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.gimagereader
  ];
}
