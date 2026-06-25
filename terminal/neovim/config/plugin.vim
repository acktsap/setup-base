"""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Configs

""" Colorscheme (Modern & Professional)
silent! colorscheme kanagawa-wave

""" lualine (Modern statusline)
lua require('lualine').setup { options = { theme = 'auto' } }

""" nerdtree settings
" (Note: <C-e> mapping is now handled in plugins.lua for better reliability)

" ctrl+j/k to navigate and auto-preview file
autocmd FileType nerdtree nmap <buffer> <C-j> jgo
autocmd FileType nerdtree nmap <buffer> <C-k> kgo
autocmd FileType nerdtree nmap <buffer> <C-h> o
autocmd FileType nerdtree nmap <buffer> <C-l> o

" ctrl+j/k from file view: focus nerdtree, navigate, and preview (only when nerdtree is open)
nmap <silent> <C-j> :if exists("g:NERDTree") && g:NERDTree.IsOpen() <Bar> NERDTreeFocus <Bar> normal jgo <Bar> endif<CR>
nmap <silent> <C-k> :if exists("g:NERDTree") && g:NERDTree.IsOpen() <Bar> NERDTreeFocus <Bar> normal kgo <Bar> endif<CR>

""" ctrlpvim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

""" tagbar
nmap <F4> :TagbarToggle<CR>
