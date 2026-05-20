{ pkgs, ... }:

{
  # Install Vim system-wide as a reliable fallback
  environment.systemPackages = with pkgs; [
    vim
  ];

  # Global Vim configuration for the "select-act-escape" rhythm
  environment.etc."vimrc".text = ''
    set nocompatible
    syntax on
    set termguicolors

    " --- THE SECRET SAUCE ---
    " These comments use " because this is Vimscript
    " Transparency fix for terminal consistency
    autocmd SourcePost * highlight Normal guibg=NONE ctermbg=NONE
    autocmd SourcePost * highlight NonText guibg=NONE ctermbg=NONE

    " UI & Navigation
    set number
    set relativenumber
    set cursorline

    " Indentation
    set expandtab
    set shiftwidth=2
    set softtabstop=2
    set smartindent

    " Clipboard & Responsiveness
    set clipboard=unnamedplus
    set ttimeout
    set ttimeoutlen=100
  '';
}
