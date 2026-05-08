{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Important for Steam and certain Wine apps
  };
