# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/apple-tools.nix (iOS USB & APFS Support)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 29 & 30):
#   Enables the 'usbmuxd' socket daemon, adds kernel APFS support, and installs
#   'libimobiledevice' and 'ifuse' so Linux workstations can inspect, pair, pull
#   UDID/serial/IMEI inventory metrics for Snipe-IT, and mount iPhones/iPads.
# ==============================================================================

{ pkgs, ... }:

{
  services.usbmuxd.enable = true;
  boot.supportedFilesystems = [ "apfs" ];

  environment.systemPackages = with pkgs; [
    libimobiledevice  # CLI toolset ('ideviceinfo', 'idevicepair') for iOS asset auditing
    ifuse             # Allows mounting iPhone/iPad filesystems over USB via FUSE
    apfs-fuse         # APFS userspace mount and inspection tools
  ];
}
