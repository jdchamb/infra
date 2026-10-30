# ==============================================================================
# NIXOS HARDWARE MODULE: modules/nixos/hardware/apple-keyboard.nix
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 6 & 8):
#   Resolves two hardware quirks when using Apple Magic/Aluminum keyboards on
#   Linux workstations:
#     1. Project 8 (Top-Row Fn Swap): Configures the kernel 'hid_apple' driver with
#        'fnmode=2' so pressing F1-F12 sends standard function key scancodes by
#        default (holding 'Fn' triggers media/brightness actions).
#     2. Project 6 (NumLock Enforcement): Forces NumLock ON across Linux virtual
#        consoles (TTYs), SDDM sessions ('numlockx'), and Wayland compositors so
#        the 10-key numeric pad works immediately upon boot.
# ==============================================================================

{ config, lib, pkgs, ... }:

{
  # --- 1. Kernel HID Driver Overrides (Project 8: F1-F12 Default Top-Row) ---
  boot.kernelModules = [ "hid-apple" ];

  # fnmode=2: F1-F12 behave as standard function keys; Fn+F1-F12 behave as media keys
  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
  '';

  # --- 2. Virtual Console & Graphical NumLock Activation (Project 6) ---
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

  # Ensure SDDM initializes with NumLock enabled
  services.displayManager.sddm.settings.General.Numlock = lib.mkDefault "on";

  # Install 'numlockx' and 'kbd' for X11/Wayland/TTY NumLock state control
  environment.systemPackages = with pkgs; [
    numlockx
    kbd
  ];
}
