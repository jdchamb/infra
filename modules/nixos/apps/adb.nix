# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/adb.nix (Android ADB & ClearTouch Profiles)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 27 — 1-to-1 Module for Android Debug Bridge):
#   Installs 'android-tools' ('adb', 'fastboot') and the custom 'ct-profile-setup'
#   CLI helper designed to configure multi-user Android profiles on USD 308
#   ClearTouch interactive panels (retaining Google Play Store on the Admin user
#   while defaulting classroom sessions to a restricted secondary user profile).
# ==============================================================================

{ config, pkgs, ... }:

let
  ctProfileSetup = pkgs.writeShellScriptBin "ct-profile-setup" ''
    set -euo pipefail
    BOARD_IP="''${1:-}"
    RESTRICTED_USER_NAME="''${2:-Classroom}"

    if [ -z "$BOARD_IP" ]; then
      echo "Usage: ct-profile-setup <cleartouch-ip> [profile-name]"
      echo "Example: ct-profile-setup 10.14.20.45 Classroom"
      exit 1
    fi

    echo "==> [1/4] Connecting to ClearTouch Android board at $BOARD_IP:5555..."
    ${pkgs.android-tools}/bin/adb connect "$BOARD_IP:5555"

    echo "==> [2/4] Auditing existing Android user profiles on board..."
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm list users

    echo "==> [3/4] Enabling multi-user switcher UI & creating '$RESTRICTED_USER_NAME' profile..."
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell settings put global user_switcher_enabled 1
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm create-user "$RESTRICTED_USER_NAME" || true

    echo "==> [4/4] Updated user list (use 'adb -s $BOARD_IP:5555 shell am switch-user <ID>' to switch default):"
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm list users
  '';
in
{
  environment.systemPackages = [
    pkgs.android-tools
    ctProfileSetup
  ];
}
