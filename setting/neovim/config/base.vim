"""""""""""""""""""""""""""""""""""""""""""""
"" Base, For more information ':help option-summary'

" rendering
set encoding=utf-8

" syntax
set showmatch            " showmatch, show matching parenthesis
set cursorline           " highlight cursor line
syntax on
" color desert            " default theme

" line number
set nu                   " number
set rnu                  " relativenumber
set numberwidth=3        " number width

" status bar, replaced with 'vim-airline' plugin
" set ru                   " ruler, show cursor position on a status bar
" set ls=2                 " laststatus, show status bar, 0 (none), 1 (not display on single window), 2 (always)

" search
set hls                  " hlsearch, highlight matches, :noh to remove highlight
set ic                   " ignorecase, can search uppercase with lowercase
set smartcase            " when search is uppercase, ignore lowercase
set incsearch            " increment search, search as characters are entered

" space
set ts=2                 " tabstop
set et                   " expandtab, tab are spaces
set ai                   " autoindent
set smartindent          " add smartly based on language
set shiftwidth=2         " width on operations like >>, <<
set wrap                 " wrap lines longer than the width of the window

" file
set autoread             " automatically apply file changes outside of vim
set nobackup             " no backup file
set noswapfile           " no swap file

" env
set nocompatible         " Disable vi-compatibility, required for Vundle
set visualbell           " don't beep
set noerrorbells         " don't beep
set confirm              " raise a confirm dislogue on unsaved changes
set history=1000         " vim command history count, saved in ~/.viminfo