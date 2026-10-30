# ==============================================================================
# SHARED SECURITY MODULE: modules/shared/security/keepassxc.nix (KeePassXC)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 1):
#   Deploys KeePassXC, an offline, open-source KDBX password and TOTP vault
#   with hardware FIDO2/YubiKey challenge-response support.
#   - On Linux: Installs 'pkgs.keepassxc' via Nixpkgs.
#   - On macOS: Installs 'keepassxc-cli' / package on Linux while GUI is handled natively.
# ==============================================================================

{ pkgs, lib, ... }:

{
  environment.systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.keepassxc
  ];
}
