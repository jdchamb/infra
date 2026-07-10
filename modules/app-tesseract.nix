{ pkgs, ... }:

{
  # CLI Text Extraction and Document Search Engine Tools
  environment.systemPackages = with pkgs; [
    tesseract
    ocrmypdf
  ];
}
