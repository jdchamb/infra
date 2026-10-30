# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/dymo.nix (CUPS DYMO LabelWriter Driver)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 1, 19, 21, 22 — 1-to-1 Module for DYMO):
#   Registers the official 'cups-dymo' printer filter driver with the NixOS CUPS
#   printing spooler so DYMO LabelWriter thermal printers can print Chromebook,
#   ClearTouch, and HVS asset tags natively.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When you plug a USB DYMO LabelWriter thermal printer into Linux, the OS sees
#   the USB device, but CUPS (the print server) doesn't know how to convert a
#   barcode PDF into the proprietary black-and-white thermal dot raster that DYMO
#   hardware expects. Adding 'pkgs.cups-dymo' to 'services.printing.drivers'
#   injects the PPD/filter files into CUPS so the printer works out-of-the-box.
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Enable CUPS and register the DYMO thermal printer drivers
  services.printing = {
    enable = true;
    drivers = [
      pkgs.cups-dymo
    ];
  };

  # 2. Also expose the driver package utilities on the system PATH
  environment.systemPackages = [
    pkgs.cups-dymo
  ];
}
