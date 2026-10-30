# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/keepassxc.nix (KeePassXC)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 1):
#   Deploys KeePassXC, an offline, open-source KDBX password and TOTP vault
#   with hardware FIDO2/YubiKey challenge-response support.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   While Vaultwarden/Bitwarden provides cloud-synced team passwords, every
#   infrastructure engineer also needs a 100% offline, local-file password
#   database ('.kdbx') for break-glass root credentials, router recovery logins,
#   and master secrets that must work even if the network or server stack is down.
#   KeePassXC encrypts this database locally using AES-256 / ChaCha20 and can
#   require a physical hardware security key touch to unlock.
# ==============================================================================

{ pkgs, lib, ... }:

{
  # Install KeePassXC on Linux/NixOS nodes (macOS GUI apps are managed via Homebrew)
  environment.systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.keepassxc
  ];
}
