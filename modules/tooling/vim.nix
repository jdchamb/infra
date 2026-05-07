{ pkgs, ... }:

{
# Install Vim system-wide
	environment.systemPackages = with pkgs; [
		vim
	];

# Set Vim as the default editor for all users
	environment.variables.EDITOR = "vim";

# Global Vim configuration for the "select-act-escape" rhythm
	environment.etc."vimrc".text = ''
		set nocompatible
		syntax on
		set number           " Show line numbers
		set relativenumber   " Relative line numbers for easier jumping
		set expandtab        " Use spaces instead of tabs
		set shiftwidth=2     " Set indentation to 2 spaces
		set softtabstop=2
		set smartindent
		set clipboard=unnamedplus " Use system clipboard if available

		" Keep your mastered Visual Block mode (Ctrl-v) standard
		" and ensure the escape key is responsive
		set ttimeout
		set ttimeoutlen=100
		'';
}
