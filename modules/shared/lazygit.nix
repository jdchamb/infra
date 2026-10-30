# ==============================================================================
# SHARED MODULE: modules/shared/lazygit.nix (Terminal UI for Git Operations)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs 'lazygit' across Linux and macOS nodes for interactive hunk staging,
#   branch rebasing, commit graph visualization, and signed commit workflows.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.lazygit
  ];
}
