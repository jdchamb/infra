set nocompatible
syntax on
set termguicolors

" --- THE SECRET SAUCE ---
" This tells Vim: 'Don't use your own background color, use the Terminal's'
autocmd SourcePost * highlight Normal guibg=NONE ctermbg=NONE
autocmd SourcePost * highlight NonText guibg=NONE ctermbg=NONE

" UI Essentials
set number
set cursorline

" Give Vim permission to use your Ghostty's specific colors
if &term =~# 'xterm' || &term =~# 'ghostty'
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif
