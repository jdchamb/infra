# ==============================================================================
# SHARED MODULE: modules/shared/lazygit.nix (Terminal UI for Git Operations)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Installs 'lazygit' across Linux and macOS nodes for interactive hunk staging,
#   branch rebasing, commit graph visualization, and signed commit workflows.
#
# WHY THIS EXISTS (NOVICE EXPLANATION):
#   Complex Git operations—like staging only 3 lines of a file, interactive
#   rebasing to squash commits, or resolving merge conflicts—can be tedious and
#   error-prone using raw CLI commands. Running 'lazygit' inside any repository
#   opens a keyboard-driven visual dashboard right inside your terminal.
#
# QUICK USAGE CHEAT SHEET:
#   - Run 'lazygit' inside any Git folder.
#   - Press 'Space' on a file to stage/unstage it.
#   - Press 'Enter' on a file to stage individual lines.
#   - Press 'c' to commit, 'P' to push, 'p' to pull, or 'q' to quit.
# ==============================================================================

{ pkgs, ... }:

{
  # Install 'lazygit' into the system-wide PATH on both NixOS and macOS
  environment.systemPackages = [
    pkgs.lazygit
  ];
}
