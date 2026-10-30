# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/apple-keyboard.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 6 & 8 — Apple Peripheral Integration):
#   Resolves hardware quirks when using Apple Magic Keyboards and USB Aluminum
#   Keyboards on NixOS workstations:
#     1. Project 8 (Function Key Swap): Configures the Linux kernel 'hid_apple'
#        driver with 'fnmode=2' so top-row keys (F1-F12) act as traditional function
#        keys by default, requiring the Fn key only for volume/media controls.
#     2. Project 6 (NumLock Enforcement): Automatically turns NumLock ON across
#        all Linux virtual consoles (TTY 1-6), display managers (SDDM), and desktop
#        sessions so the 10-key numeric keypad enters numbers immediately on boot.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   - Apple Function Key Quirk: On macOS, pressing F1 dims the screen and F11/F12
#     adjust volume. In Linux developer workflows, you need F1-F12 for terminal
#     shortcuts, IDE debugging (F5), renaming files (F2), and full-screen toggles (F11).
#     The 'hid-apple' kernel driver option 'fnmode=2' restores the standard PC behavior:
#     F1-F12 send standard F-key scancodes; holding Fn triggers the special actions.
#   - Apple Numeric Keypad Quirk: Apple keyboards with numeric pads do not have
#     a physical NumLock button or LED. Linux boots with NumLock turned OFF by
#     default, which causes the numeric pad to send navigation commands (Page Down,
#     Arrow keys) instead of numbers!
#     This module forces the NumLock LED state ON across both text virtual terminals
#     (TTYs via 'setleds') and graphical login screens (SDDM via 'numlockx').
#
# HOW TO USE:
#   - Import this module into any NixOS workstation host that uses an Apple keyboard:
#       imports = [ ../../modules/nixos/hardware/apple-keyboard.nix ];
#   - Verify kernel driver parameter:
#       cat /sys/module/hid_apple/parameters/fnmode  (Should return '2')
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --------------------------------------------------------------------------
  # 1. Kernel HID Driver Overrides (Project 8: Top-Row Function Keys)
  # --------------------------------------------------------------------------
  # Load the Apple Human Interface Device (HID) driver into the running kernel
  boot.kernelModules = [ "hid-apple" ];

  # Configure driver options:
  #   fnmode=0: Fn key disabled
  #   fnmode=1: Media keys are default, Fn required for F1-F12 (Apple default)
  #   fnmode=2: F1-F12 are default, Fn required for media keys (PC standard)
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # --------------------------------------------------------------------------
  # 2. Virtual Console NumLock Activation (Project 6)
  # Runs 'setleds +num' on virtual terminals tty1 through tty6 on startup
  # --------------------------------------------------------------------------
  systemd.services."numlock-tty" = {
    description = "Activate NumLock on Virtual Console TTYs (Project 6)";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-vconsole-setup.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      for tty in /dev/tty[1-6]; do
        ${pkgs.kbd}/bin/setleds -D +num < "$tty" || true
      done
    '';
  };

  # --------------------------------------------------------------------------
  # 3. Graphical Display Manager (SDDM) NumLock Enforcement
  # --------------------------------------------------------------------------
  services.displayManager.sddm.settings.General.Numlock = lib.mkDefault "on";

  # --------------------------------------------------------------------------
  # 4. User Utilities
  # --------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    numlockx  # CLI utility to turn on NumLock under X11 graphical sessions
    kbd       # Linux console and font management tools (provides 'setleds')
  ];
}
