# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/gpg.nix (GnuPG Identity Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 5):
#   Configures GnuPG cryptographic identity tooling across both Linux and macOS,
#   and activates the system-level GnuPG Agent + PC/SC smartcard daemon on NixOS
#   for signed developer Git workflows.
# ==============================================================================

{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        gnupg
        pinentry-curses
        ssh-to-age
        paperkey
      ] ++ lib.optionals pkgs.stdenv.isDarwin [
        pinentry_mac
      ];
    }

    (lib.optionalAttrs (options ? programs && options.programs ? gnupg) {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      } // lib.optionalAttrs (!pkgs.stdenv.isDarwin) {
        pinentryPackage = pkgs.pinentry-curses;
      };
    })

    (lib.optionalAttrs (options ? services && options.services ? pcscd) {
      services.pcscd.enable = true;
    })
  ];
}
