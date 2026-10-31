# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/gpg.nix (GnuPG Identity Engine)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 5):
#   Configures GnuPG cryptographic identity tooling across both Linux and macOS,
#   and activates the system-level GnuPG Agent + PC/SC smartcard daemon on NixOS
#   for signed developer Git workflows and hardware security keys.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Cryptographic identity lets you digitally sign Git commits and encrypt files
#   so collaborators and servers can mathematically prove a change came from you.
#   - 'gnupg' (gpg): The core OpenPGP encryption and signing engine.
#   - 'pinentry': The secure prompt that asks for your key passphrase or hardware
#     PIN without exposing it to regular terminal history.
#   - 'ssh-to-age': Converts standard SSH Ed25519 keys into 'age' encryption keys
#     for our SOPS secret management workflow.
#   - 'paperkey': Extracts only the secret bytes of a GPG key so you can print a
#     compact QR/text backup on physical paper for disaster recovery.
#   - 'pcscd': The SmartCard daemon on Linux that lets GPG talk to physical USB
#     YubiKeys and Nordic OpenSK hardware tokens.
# ==============================================================================

{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      # 1. Install GnuPG and key-management utilities across both Linux and macOS
      environment.systemPackages = with pkgs; [
        gnupg           # Core GnuPG ('gpg') CLI for signing and encryption
        pinentry-curses # Terminal-based PIN/passphrase dialog (works over SSH)
        ssh-to-age      # Bridges SSH Ed25519 keys with SOPS/Age secret files
        paperkey        # Printable disaster-recovery backup generator for private keys
      ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
        pinentry_mac    # Native macOS Keychain-integrated GUI passphrase dialog
      ];
    }

    # 2. Configure the background GPG Agent (Caches passphrases & bridges SSH)
    (lib.optionalAttrs (options ? programs && options.programs ? gnupg) {
      programs.gnupg.agent = {
        enable = true;
        # Allow gpg-agent to act as an ssh-agent so hardware PGP authentication
        # subkeys can also authenticate SSH connections (e.g. to Codeberg/servers)
        enableSSHSupport = true;
      } // lib.optionalAttrs (!pkgs.stdenv.hostPlatform.isDarwin) {
        # Note: 'pinentryPackage' is a NixOS-specific module option; nix-darwin
        # does not define this option, so we guard it with '!pkgs.stdenv.hostPlatform.isDarwin'.
        pinentryPackage = pkgs.pinentry-curses;
      };
    })

    # 3. Enable the PC/SC SmartCard Daemon on NixOS (Required for USB YubiKeys)
    (lib.optionalAttrs (options ? services && options.services ? pcscd) {
      services.pcscd.enable = true;
    })
  ];
}
