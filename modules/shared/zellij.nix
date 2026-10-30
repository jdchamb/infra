# ==============================================================================
# SHARED MODULE: modules/shared/zellij.nix (Terminal Workspace Multiplexer)
# ==============================================================================
#
# ROLE & ARCHITECTURE (Personal Project 7):
#   Installs Zellij system-wide across Linux and macOS and provisions a
#   declarative KDL configuration implementing the Universal Environment
#   Keybinding Pattern:
#     - 'Alt + h/j/k/l': Seamless directional pane focus (matches Super+h/j/k/l in WM)
#     - 'Alt + n': Spawn new terminal pane
#     - 'Alt + t': Spawn new workspace tab
#     - 'Alt + x': Close active pane
#     - 'Alt + 1..9': Jump directly to tab 1..9
#     - 'Alt + f': Toggle floating terminal pane
# ==============================================================================

{ pkgs, ... }:

{
  # 1. Install Zellij globally across Linux and macOS nodes
  environment.systemPackages = with pkgs; [
    zellij
  ];

  # 2. Declarative User-Space Zellij Configuration (Project 7)
  home-manager.users.jchambers.home.file.".config/zellij/config.kdl".text = ''
    // --- Zellij Universal Environment Keybinding & Styling Matrix (Project 7) ---
    theme "catppuccin-mocha"
    simplified_ui true
    pane_frames false
    default_layout "compact"
    copy_on_select true
    scroll_buffer_size 10000

    keybinds {
        shared_except "locked" {
            // Directional Vim Pane Navigation (Alt + H/J/K/L)
            bind "Alt h" { MoveFocusOrTab "Left"; }
            bind "Alt l" { MoveFocusOrTab "Right"; }
            bind "Alt j" { MoveFocus "Down"; }
            bind "Alt k" { MoveFocus "Up"; }

            // Pane & Tab Lifecycle
            bind "Alt n" { NewPane; }
            bind "Alt d" { NewPane "Right"; }
            bind "Alt s" { NewPane "Down"; }
            bind "Alt x" { CloseFocus; }
            bind "Alt f" { ToggleFloatingPanes; }
            bind "Alt z" { ToggleFocusFullscreen; }
            bind "Alt t" { NewTab; }

            // Pane Resizing
            bind "Alt =" "Alt +" { Resize "Increase"; }
            bind "Alt -" { Resize "Decrease"; }

            // Direct Tab Jumping (Alt + 1..9)
            bind "Alt 1" { GoToTab 1; }
            bind "Alt 2" { GoToTab 2; }
            bind "Alt 3" { GoToTab 3; }
            bind "Alt 4" { GoToTab 4; }
            bind "Alt 5" { GoToTab 5; }
            bind "Alt 6" { GoToTab 6; }
            bind "Alt 7" { GoToTab 7; }
            bind "Alt 8" { GoToTab 8; }
            bind "Alt 9" { GoToTab 9; }
        }
    }
  '';
}
