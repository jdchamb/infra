# ==============================================================================
# SHARED MODULE: modules/shared/neovim.nix (Primary Modern Editor)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Deploys Neovim as the primary terminal editor across the entire fleet.
#   - Sets Neovim as the system default $EDITOR.
#   - Bundles essential native build dependencies (gcc, make, curl, unzip)
#     required by Treesitter parsers and Mason/LSP installers.
#   - Injects a resilient minimal fallback configuration in case external
#     dotfiles are missing or being bootstrapped on a fresh machine.
# ==============================================================================

{ pkgs, lib, options, ... }:

{
  config = lib.mkMerge [
    {
      # Essential build tools and utilities required for Neovim LSP / Treesitter compiling
      environment.systemPackages = with pkgs; [
        neovim
        git
        gnumake
        gcc
        unzip
        wget
        curl
      ];
    }

    # Declarative Neovim configuration (Active on NixOS nodes)
    (lib.optionalAttrs (options ? programs && options.programs ? neovim) {
      programs.neovim = {
        enable = true;
        defaultEditor = true; # Exports EDITOR=nvim system-wide
        viAlias = true;       # Maps 'vi' to nvim
        vimAlias = true;      # Maps 'vim' to nvim

        # Safe, minimal fallback defaults built directly into Nix
        configure = {
          customRC = ''
            " Minimal fallback configuration for emergency recovery
            set number
            set relativenumber
            set shiftwidth=2
            set tabstop=2
            set expandtab
          '';
        };
      };
    })
  ];
}

