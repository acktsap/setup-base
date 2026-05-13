" Set runtimepath to include the current config directory
let s:config_dir = expand('<sfile>:p:h')
let &rtp .= ',' . s:config_dir

" Add the lua directory to the lua search path
lua << EOF
  local config_dir = vim.fn.expand('<sfile>:p:h')
  package.path = package.path .. ';' .. config_dir .. '/lua/?.lua'
  package.path = package.path .. ';' .. config_dir .. '/lua/?/init.lua'
EOF

" load plugins (modern lazy.nvim)
lua require('plugins')

" load base, plugin
execute 'source ' . s:config_dir . '/base.vim'
execute 'source ' . s:config_dir . '/plugin.vim'

" load completion & LSP (lua)
lua require('lsp')
lua require('completion')

" load per extentions
au BufNewFile,BufRead *.java execute 'source ' . s:config_dir . '/java.vim'
au BufNewFile,BufRead *.c execute 'source ' . s:config_dir . '/c.vim'
au BufNewFile,BufRead *.cpp execute 'source ' . s:config_dir . '/cpp.vim'
au BufNewFile,BufRead *.go execute 'source ' . s:config_dir . '/go.vim'
au BufNewFile,BufRead *.sh execute 'source ' . s:config_dir . '/shell-script.vim'
