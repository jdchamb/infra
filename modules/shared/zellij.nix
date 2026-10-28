# ==============================================================================
# SHARED MODULE: modules/shared/zellij.nix (Terminal Workspace Multiplexer)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Zellij is a modern terminal workspace multiplexer and session manager (like tmux).
#   - Provides intuitive UI-driven tabs, pane splitting, and layout automation.
#   - Enables long-running background tasks to survive SSH disconnections.
#   - Available across both Linux and macOS nodes.
# ==============================================================================

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zellij
  ];
}
