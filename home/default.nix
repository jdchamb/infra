# ==============================================================================
# USER-SPACE PROFILE: home/default.nix (Home Manager Entry Point)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   This module defines the unified user environment for 'jchambers' across
#   ALL machines in the fleet (macOS MacBook, Linux workstation, and Linux VM).
#
# HOW HOME MANAGER WORKS IN THIS FLEET:
#   1. In flake.nix, 'mkNixos' and 'mkDarwin' automatically import this file.
#   2. On macOS, the user directory evaluates to '/Users/jchambers'.
#   3. On Linux/NixOS, it evaluates to '/home/jchambers'.
#   4. Any dotfiles, shell plugins, prompts, or user packages added here
#      will instantly propagate to every machine upon running 'rebuild'.
# ==============================================================================

{ config, pkgs, inputs, ... }:

{
  # ----------------------------------------------------------------------------
  # USER IDENTITY & HOME DIRECTORY RESOLUTION
  # ----------------------------------------------------------------------------
  home = {
    username = "jchambers";

    # Dynamic path detection: macOS places homes in /Users, Linux in /home
    homeDirectory = if pkgs.stdenv.isDarwin then "/Users/jchambers" else "/home/jchambers";

    # Home Manager state version (determines compatibility defaults)
    stateVersion = "24.11";
  };

  # Let Home Manager install and manage its own internal CLI wrapper
  programs.home-manager.enable = true;

  # ----------------------------------------------------------------------------
  # MODULAR USER PROGRAMS
  # ----------------------------------------------------------------------------
  # Interactive shell and terminal styling modules
  imports = [
    ./programs/zsh.nix      # Zsh shell, fzf, zoxide, history, and rebuild script
    ./programs/git-sync.nix # Zsh chpwd auto-fetch & rebase prompt hook
    ./programs/starship.nix # Starship cross-shell prompt (Catppuccin Mocha theme)
  ];
}
