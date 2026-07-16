"""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Configs

""" Colorscheme
set termguicolors
silent! colorscheme onehalfdark

""" lualine (Modern statusline)
lua require('lualine').setup { options = { theme = 'auto' } }

""" ctrlpvim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

""" tagbar
nmap <F4> :TagbarToggle<CR>
