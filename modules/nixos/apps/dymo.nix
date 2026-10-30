# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/dymo.nix (CUPS DYMO LabelWriter Driver)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 1, 19, 21, 22 — 1-to-1 Module for DYMO):
#   Registers the official 'cups-dymo' printer filter driver with the NixOS CUPS
#   printing spooler so DYMO LabelWriter thermal printers can print Chromebook,
#   ClearTouch, and HVS asset tags natively.
# ==============================================================================

{ config, pkgs, ... }:

{
  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-dymo
    ];
  };

  environment.systemPackages = [
    pkgs.cups-dymo
  ];
}
