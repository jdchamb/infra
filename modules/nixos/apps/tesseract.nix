# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/tesseract.nix (Tesseract CLI OCR Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Tesseract & OCRmyPDF):
#   Installs the Tesseract optical character recognition engine and 'ocrmypdf'
#   to convert flat scanned PDF documents into text-searchable PDF/A archives.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tesseract
    ocrmypdf
  ];
}
