# ==============================================================================
# FLEET SECURITY MODULE: modules/shared/security/yubikey-nordic.nix
# ==============================================================================
#
# WHAT IS THIS MODULE?
#   This module sets up physical hardware security keys across the entire fleet.
#   It works seamlessly on both Apple Silicon macOS (nix-darwin) and bare-metal
#   or virtual Linux workstations (NixOS).
#
# SUPPORTED HARDWARE:
#   1. Official Yubico YubiKeys (YubiKey 5 Series, Security Key NFC, etc.)
#   2. Nordic Semiconductor nRF52840 Dongles flashed with Google OpenSK
#      (Both when reporting native Nordic 0x1915 or patched Yubico 0x1050 IDs)
#
# WHY DO WE NEED THIS CONFIGURATION?
#   - On Linux (NixOS), the kernel by default restricts direct raw USB and HID
#     access to the 'root' administrator. Without 'udev' rules, ordinary users
#     cannot tap their security key to log in or use WebAuthn in their browser.
#   - This module installs the 'uaccess' tag, which dynamically gives whoever is
#     currently sitting at the physical keyboard/screen permission to use the key.
#   - It also enables PAM (Pluggable Authentication Modules), allowing you to
#     touch your physical key to authenticate 'sudo' in terminal or log into your desktop.
#   - On macOS (nix-darwin), it provides the CLI utilities (libfido2, pam_u2f) while
#     safely skipping Linux-only udev and PAM configurations.
# ==============================================================================

{ pkgs, lib, options, config, ... }:

{
  config = lib.mkMerge [
    # --------------------------------------------------------------------------
    # 1. CORE CROSS-PLATFORM PACKAGES (Installed on both macOS and NixOS)
    # --------------------------------------------------------------------------
    {
      environment.systemPackages = with pkgs; [
        # libfido2 provides the standard C library and CLI tools ('fido2-token',
        # 'fido2-assert', 'fido2-cred') used by browsers and applications to talk
        # to FIDO2 / CTAP2 security keys.
        libfido2

        # pam_u2f is the official Pluggable Authentication Module that allows
        # physical key taps to unlock sudo, login managers, and screen lockers.
        pam_u2f

        # yubikey-manager provides the 'ykman' CLI tool for inspecting and
        # configuring YubiKey features and FIDO PINs.
        yubikey-manager
      ];
    }

    # --------------------------------------------------------------------------
    # 2. LINUX HARDWARE ACCESS RULES (NixOS Only)
    # --------------------------------------------------------------------------
    # Explanation: 'options ? services && options.services ? udev' checks if the
    # host operating system is NixOS. If this is macOS, this block is safely skipped
    # so nix-darwin evaluation does not fail.
    (lib.optionalAttrs (options ? services && options.services ? udev) {
      services.udev = {
        # Packages containing pre-built udev rules for security tokens
        packages = with pkgs; [
          yubikey-personalization
          libfido2
        ];

        # Custom hardware rules for Nordic Semiconductor and standard FIDO tokens:
        # - KERNEL=="hidraw*": Matches raw Human Interface Devices (how FIDO talks).
        # - ATTRS{idVendor}=="1915": Nordic Semiconductor's USB Vendor ID.
        # - ATTRS{idVendor}=="1050": Yubico's official USB Vendor ID.
        # - TAG+="uaccess": Grants permission to the currently active logged-in seat.
        # - MODE="0660", GROUP="users": Grants read/write to the 'users' group.
        extraRules = ''
          # Nordic Semiconductor OpenSK / nRF52840 Security Key
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1915", TAG+="uaccess", MODE="0660", GROUP="users"
          SUBSYSTEM=="usb", ATTR{idVendor}=="1915", TAG+="uaccess", MODE="0660", GROUP="users"

          # Yubico Hardware Keys and Yubico-Identified OpenSK Dongles
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", TAG+="uaccess", MODE="0660", GROUP="users"
          SUBSYSTEM=="usb", ATTR{idVendor}=="1050", TAG+="uaccess", MODE="0660", GROUP="users"
        '';
      };
    })

    # --------------------------------------------------------------------------
    # 3. PAM U2F AUTHENTICATION INTEGRATION (NixOS Only)
    # --------------------------------------------------------------------------
    # Enables system-level PAM authentication so that touching your physical key
    # can authorize terminal operations or graphical lockscreen logins.
    (lib.optionalAttrs (options ? security && options.security ? pam && options.security.pam ? u2f) {
      security.pam.u2f = {
        enable = true;
        settings = {
          # 'cue = true' prints a helpful terminal prompt: "Please touch the device."
          cue = true;

          # 'origin' specifies the application domain for the PAM challenge.
          origin = "pam://local";

          # Path to the authorization mapping file (generated via 'pamu2fcfg > /etc/u2f_mappings')
          authfile = "/etc/u2f_mappings";
        };
      };
    })

    # --------------------------------------------------------------------------
    # 4. macOS SUDO AUTHENTICATION: TOUCH ID + SECURITY KEY (nix-darwin Only)
    # --------------------------------------------------------------------------
    # Declaratively manages /etc/pam.d/sudo_local (replaces the hand-edited file).
    # Order matters: PAM tries each 'sufficient' line top-down, first success wins.
    #   1. pam_reattach - lets Touch ID work inside Zellij / tmux sessions.
    #   2. pam_tid      - Touch ID fingerprint.
    #   3. pam_u2f      - FIDO2 key tap (Nordic OpenSK / YubiKey), fallback.
    # Key enrollment (one per key, run on each Mac):
    #   mkdir -p ~/.config/Yubico
    #   pamu2fcfg > ~/.config/Yubico/u2f_keys      # first key
    #   pamu2fcfg -n >> ~/.config/Yubico/u2f_keys  # each additional/backup key
    # NOTE: pam_u2f defaults origin to pam://<hostname>, so re-run pamu2fcfg
    # if the hostname changes.
    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      security.pam.services.sudo_local = {
        touchIdAuth = true;
        reattach = true;
        text = lib.mkAfter ''
          auth       sufficient     ${pkgs.pam_u2f}/lib/security/pam_u2f.so cue
        '';
      };
    })
  ];
}
