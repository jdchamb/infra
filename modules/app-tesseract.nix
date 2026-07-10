{ pkgs, ... }:

let
  # Correct way to append language dictionaries to the base tesseract package
  tesseractCustom = pkgs.tesseract.override {
    enableDefaultLanguages = false; # Disables pulling the entire global language set if unwanted
    languages = [ "eng" ];          # Pins English cleanly
  };
in {
  # CLI Text Extraction and Document Search Engine Tools
  environment.systemPackages = [
    tesseractCustom
    pkgs.ocrmypdf
  ];
}
