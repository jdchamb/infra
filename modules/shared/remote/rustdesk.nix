# ==============================================================================
# SHARED REMOTE MODULE: modules/shared/remote/rustdesk.nix (RustDesk Remote Client)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Fleet Services Roadmap Phase 1):
#   Deploys the open-source RustDesk remote desktop client on Linux nodes as a
#   self-hosted, privacy-respecting alternative to TeamViewer and AnyDesk.
# ==============================================================================

{ pkgs, lib, ... }:

{
  environment.systemPackages = lib.optionals (!pkgs.stdenv.isDarwin) [
    pkgs.rustdesk-flutter
  ];
}
