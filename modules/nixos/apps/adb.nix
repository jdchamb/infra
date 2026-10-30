# ==============================================================================
# NIXOS APP MODULE: modules/nixos/apps/adb.nix (Android ADB & ClearTouch Profiles)
# ==============================================================================
#
# ROLE & ARCHITECTURE (308 Project 27 — 1-to-1 Module for Android Debug Bridge):
#   Installs 'android-tools' ('adb', 'fastboot') and the custom 'ct-profile-setup'
#   CLI helper designed to configure multi-user Android profiles on USD 308
#   ClearTouch interactive panels (retaining Google Play Store on the Admin user
#   while defaulting classroom sessions to a restricted secondary user profile).
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   ADB (Android Debug Bridge) is the official tool for sending commands to an
#   Android device over USB or the network (port 5555). ClearTouch boards are
#   Android devices, so ADB lets us manage them remotely.
#
#   The goal of 308 Project 27: teachers/students should NOT be able to install
#   random apps, but the admin account should still have the Play Store.
#   Android supports multiple user profiles (like a shared PC), so the helper
#   script below automates:
#     1. Connecting to the board over the network.
#     2. Listing existing user profiles.
#     3. Turning on the user switcher and creating a restricted profile.
#     4. Showing the new list so you can switch the default profile.
#
#   'pkgs.writeShellScriptBin' turns the script into a real command named
#   'ct-profile-setup' with the exact adb path baked in, so it works even if
#   adb is not otherwise on PATH.
# ==============================================================================

{ config, pkgs, ... }:

let
  ctProfileSetup = pkgs.writeShellScriptBin "ct-profile-setup" ''
    set -euo pipefail                       # Stop on any error or unset variable
    BOARD_IP="''${1:-}"                      # 1st argument: ClearTouch IP address
    RESTRICTED_USER_NAME="''${2:-Classroom}" # 2nd argument (optional): profile name

    if [ -z "$BOARD_IP" ]; then
      echo "Usage: ct-profile-setup <cleartouch-ip> [profile-name]"
      echo "Example: ct-profile-setup 192.168.1.50 Classroom"
      exit 1
    fi

    echo "==> [1/4] Connecting to ClearTouch Android board at $BOARD_IP:5555..."
    ${pkgs.android-tools}/bin/adb connect "$BOARD_IP:5555"

    echo "==> [2/4] Auditing existing Android user profiles on board..."
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm list users

    echo "==> [3/4] Enabling multi-user switcher UI & creating '$RESTRICTED_USER_NAME' profile..."
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell settings put global user_switcher_enabled 1
    # '|| true' = don't abort if the profile already exists (makes the script safe to re-run)
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm create-user "$RESTRICTED_USER_NAME" || true

    echo "==> [4/4] Updated user list (use 'adb -s $BOARD_IP:5555 shell am switch-user <ID>' to switch default):"
    ${pkgs.android-tools}/bin/adb -s "$BOARD_IP:5555" shell pm list users
  '';
in
{
  # Install Android platform tools (adb, fastboot) plus our ClearTouch helper
  environment.systemPackages = [
    pkgs.android-tools
    ctProfileSetup
  ];
}
