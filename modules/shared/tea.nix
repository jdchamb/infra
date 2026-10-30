# ==============================================================================
# SHARED MODULE: modules/shared/tea.nix (Codeberg / Forgejo / Gitea CLI)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Projects 12 & 24):
#   Installs the official 'tea' CLI client for interacting with Codeberg and
#   self-hosted Forgejo instances (managing issues, pull requests, releases,
#   and repositories directly from the terminal).
# ==============================================================================

{ pkgs, lib, ... }:

{
  # On macOS, 'tea' is also available via Homebrew or Nixpkgs
  environment.systemPackages = [
    pkgs.tea
  ];
}
