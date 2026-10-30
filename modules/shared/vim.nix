# ==============================================================================
# SHARED MODULE: modules/shared/vim.nix (Rescue & Minimal Fallback Editor)
# ==============================================================================
#
# ROLE & ARCHITECTURE:
#   Provides standard Vim system-wide across all fleet nodes as an ultra-reliable,
#   dependency-free fallback editor. Used during system boots, rescue shells,
#   and root maintenance tasks.
#
# KEY TWEAKS:
#   - Transparent background fix (inherits terminal background color).
#   - Relative line numbers for efficient Vim motion jumps (e.g. 5j, 12k).
#   - System clipboard integration (+register / unnamedplus).
#   - 2-space soft tabs for consistent Nix / YAML editing.
# ==============================================================================

{ pkgs, ... }:

{
  # Install standard Vim globally
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Global system vimrc configuration
  environment.etc."vimrc".text = ''
    set nocompatible
    syntax on
    set termguicolors

    " --- TERMINAL TRANSPARENCY FIX ---
    " Ensures Vim respects terminal background opacity (e.g. Ghostty / Alacritty)
    autocmd SourcePost * highlight Normal guibg=NONE ctermbg=NONE
    autocmd SourcePost * highlight NonText guibg=NONE ctermbg=NONE

    " --- UI & NAVIGATION ---
    set number           " Show absolute line number on current line
    set relativenumber   " Show relative numbers above/below for motion jumps
    set cursorline       " Highlight the current active line

    " --- INDENTATION & TABS ---
    set expandtab        " Convert tabs to spaces
    set shiftwidth=2     " Indentation width
    set softtabstop=2    " Number of spaces per Tab keypress
    set smartindent      " Auto-indent new lines according to language syntax

    " --- CLIPBOARD & RESPONSIVENESS ---
    set clipboard=unnamedplus " Sync Vim default register with OS clipboard
    set ttimeout              " Fast escape key response
    set ttimeoutlen=100
  '';
}
