# ==============================================================================
# SHARED REMOTE MODULE: modules/shared/remote/rustdesk.nix (RustDesk Remote Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 1):
#   Deploys the open-source RustDesk remote desktop client on Linux nodes as a
#   self-hosted, privacy-respecting alternative to TeamViewer and AnyDesk.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Commercial remote-support tools (like TeamViewer) restrict concurrent sessions,
#   enforce aggressive "commercial use" lockouts, and route screen traffic through
#   third-party relays. RustDesk is 100% open-source, works across Linux, macOS,
#   and Windows, and can point directly to our own self-hosted rendezvous/relay
#   server so screen streams never leave our controlled network.
#
# PLATFORM NOTE:
#   We guard the Nixpkgs package with 'lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin)'
#   because the Flutter GUI package in Nixpkgs targets Linux X11/Wayland, while
#   macOS hosts install native GUI bundles via Homebrew Casks.
# ==============================================================================

{ pkgs, lib, ... }:

{
  # Install the RustDesk Flutter desktop client on Linux/NixOS machines
  environment.systemPackages = lib.optionals (!pkgs.stdenv.hostPlatform.isDarwin) [
    pkgs.rustdesk-flutter
  ];
}
