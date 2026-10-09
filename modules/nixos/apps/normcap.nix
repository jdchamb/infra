{ pkgs, ... }:

{
  # Install NormCap system-wide for quick screenshot OCR selection
  environment.systemPackages = with pkgs; [
    normcap
  ];
}
