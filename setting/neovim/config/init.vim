" load base, plugin
:source ${HOME}/.config/nvim/base.vim
:source ${HOME}/.config/nvim/plugin.vim

" load per extentions
au BufNewFile,BufRead *.java :source ${HOME}/.config/nvim/java.vim
au BufNewFile,BufRead *.go :source ${HOME}/.config/nvim/go.vim
