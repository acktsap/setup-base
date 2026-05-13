"""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Configs

""" onehalfdark
silent! colorscheme onehalfdark

""" airline
let g:airline_theme='onehalfdark'

""" nerdtree
" ne -> run nerd tree
nmap  <C-e> :NERDTreeToggle<CR>
" arrow synbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'
" ctrl+j/k to navigate and auto-preview file
autocmd FileType nerdtree nmap <buffer> <C-j> jgo
autocmd FileType nerdtree nmap <buffer> <C-k> kgo
autocmd FileType nerdtree nmap <buffer> <C-h> o
autocmd FileType nerdtree nmap <buffer> <C-l> o
" ctrl+j/k from file view: focus nerdtree, navigate, and preview (only when nerdtree is open)
nmap <silent> <C-j> :if g:NERDTree.IsOpen() <Bar> NERDTreeFocus <Bar> normal jgo <Bar> endif<CR>
nmap <silent> <C-k> :if g:NERDTree.IsOpen() <Bar> NERDTreeFocus <Bar> normal kgo <Bar> endif<CR>

""" ctrlpvim
" Shortcuts
" - Press <F5> to purge the cache
" - Press <c-d> to switch to filename only search instead of full path.
" - Press <c-r> to switch to regexp mode.
" - Use <c-j>, <c-k> or the arrow keys to navigate the result list.
" <c-p>  -> run nerd tree
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

""" tagbar
" Shortcuts
"  - ctrl
" f4 -> view tag bar
nmap <F4> :TagbarToggle<CR>
