# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/tesseract.nix (Tesseract CLI OCR Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (1-to-1 Module for Tesseract & OCRmyPDF):
#   Installs the Tesseract optical character recognition engine and 'ocrmypdf'
#   to convert flat scanned PDF documents into text-searchable PDF/A archives.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   A scanned invoice is just a picture of text—you can't search it or copy
#   from it. 'tesseract' is the OCR engine that reads text from images;
#   'ocrmypdf' wraps it to add an invisible text layer to a whole PDF while
#   keeping the original look. These two are paired because ocrmypdf cannot
#   work without tesseract; the GUI front-ends (gimagereader, normcap) live in
#   their own modules.
#
# QUICK USAGE:
#   ocrmypdf scanned-invoice.pdf searchable-invoice.pdf
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tesseract # Core OCR engine (image -> text)
    ocrmypdf  # Adds a searchable text layer to scanned PDFs using tesseract
  ];
}
