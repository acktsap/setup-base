" load base, plugin
:source ${HOME}/.config/nvim/base.vim
:source ${HOME}/.config/nvim/plugin.vim

" load per extentions
au BufNewFile,BufRead *.java :source ${HOME}/.config/nvim/java.vim
au BufNewFile,BufRead *.cpp :source ${HOME}/.config/nvim/cpp.vim
au BufNewFile,BufRead *.go :source ${HOME}/.config/nvim/go.vim
au BufNewFile,BufRead *.sh :source ${HOME}/.config/nvim/shell-script.vim
