# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/minicom.nix (RS-232 Serial Console Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 17 — 1-to-1 Module for Minicom):
#   Installs 'minicom' and grants 'jchambers' membership in the 'dialout' group
#   for direct USB-to-RJ45 serial console access (9600 8N1) to the homelab
#   Brocade ICX switch.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Network switches and routers have a "console port" that works even when the
#   network is broken or the device has no IP address yet. You plug a USB serial
#   cable in, and Linux exposes it as '/dev/ttyUSB0'.
#   - 'minicom' is the terminal program that talks over that serial line.
#   - On Linux, serial devices are owned by the 'dialout' group (a historical
#     name from dial-up modems). Without that group, you would need 'sudo'
#     every time you open the console.
#
# QUICK USAGE:
#   minicom -D /dev/ttyUSB0 -b 9600     # 9600 baud, 8 data bits, No parity, 1 stop (8N1)
# ==============================================================================

{ config, pkgs, ... }:

{
  # 1. Install the minicom serial terminal
  environment.systemPackages = [
    pkgs.minicom
  ];

  # 2. Allow 'jchambers' to open /dev/ttyUSB* and /dev/ttyACM* without sudo.
  #    NixOS merges this list with groups declared elsewhere (e.g. core/user.nix).
  users.users.jchambers.extraGroups = [ "dialout" ];
}
