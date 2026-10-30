# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/gimagereader.nix (Graphical OCR Parser)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 2 — 1-to-1 Module for gImageReader):
#   Installs the GTK front-end to Tesseract OCR ('gimagereader') for extracting
#   structured text, serial numbers, and tables from scanned PDFs and equipment
#   invoices.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When compiling lists of non-returned staff equipment or reading scanned
#   packing slips (USD 308 Project 2), re-typing long serial numbers and asset
#   tags by hand invites typos. 'gimagereader' lets you open any PDF or image,
#   draw a box around a column of serial numbers, and convert the image into
#   selectable, copy-pasteable text using Optical Character Recognition (OCR).
# ==============================================================================

{ pkgs, ... }:

{
  # Install the graphical gImageReader OCR application
  environment.systemPackages = [
    pkgs.gimagereader
  ];
}
