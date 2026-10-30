# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/apple-tools.nix (iOS USB & APFS Support)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Projects 29 & 30):
#   Enables the 'usbmuxd' socket daemon, adds kernel APFS support, and installs
#   'libimobiledevice' and 'ifuse' so Linux workstations can inspect, pair, pull
#   UDID/serial/IMEI inventory metrics for Snipe-IT, and mount iPhones/iPads.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   When processing district iPhones (308 Projects 29/30), we need the serial
#   number, IMEI, and model to enter into Snipe-IT. Linux can read those
#   directly over USB, but it needs a few pieces working together:
#     - 'usbmuxd'         : A background service that speaks Apple's USB
#                           multiplexing protocol. Without it, Linux sees the
#                           iPhone only as a charging device.
#     - 'libimobiledevice': Command-line tools (e.g. 'ideviceinfo') that ask the
#                           phone for its serial, IMEI, iOS version, etc.
#     - 'ifuse'           : Mounts the phone's photo/media storage as a folder.
#     - 'apfs' / 'apfs-fuse': Lets Linux read Apple's APFS disk format (e.g. a
#                           USB drive or disk image formatted on a Mac).
#   These are grouped because they are all parts of one job: "talk to Apple devices".
#
# QUICK USAGE:
#   idevicepair pair                                  # Tap "Trust" on the phone
#   ideviceinfo -k SerialNumber                       # Print serial for Snipe-IT
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Background daemon required for any iOS USB communication
  services.usbmuxd.enable = true;

  # 2. Teach the kernel/initrd to recognize APFS-formatted drives
  boot.supportedFilesystems = [ "apfs" ];

  # 3. User-facing tools
  environment.systemPackages = with pkgs; [
    libimobiledevice  # CLI toolset ('ideviceinfo', 'idevicepair') for iOS asset auditing
    ifuse             # Allows mounting iPhone/iPad filesystems over USB via FUSE
    apfs-fuse         # APFS userspace mount and inspection tools
  ];
}
