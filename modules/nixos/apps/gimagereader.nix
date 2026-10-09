{ pkgs, ... }:

{
  # Install gImageReader and its GTK interface for structured document OCR parsing
  environment.systemPackages = with pkgs; [
    gimagereader
  ];
}
