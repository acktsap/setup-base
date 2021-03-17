"""""""""""""""""""""""""""""""""""""""""""""
"" Plugin Configs

" Remap code completion to Ctrl+Space {{{2
" inoremap <C-Space> <C-n>

" git clone https://github.com/gmarik/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" VundleVim Setting
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just
" :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" see :h vundle for more details or wiki for FAQ
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" syntax, statusbar
Plugin 'sonph/onehalf', {'rtp': 'vim/'}   " syntax
Plugin 'scrooloose/syntastic'             " syntax check
Plugin 'vim-airline/vim-airline'          " status bar

" navigating
Plugin 'scrooloose/nerdtree'              " file view tree
Plugin 'ctrlpvim/ctrlp.vim'               " file finder
Plugin 'majutsushi/tagbar'                " show tagbar

" intellisence
" youcompleteme
"   Precondition
"     cmake installed
"     golang installed
"     pynvim : python3 -m pip install --user --upgrade pynvim
"
"   Setup
"     cd ~/.vim/bundle/YouCompleteMe
"     ./install.py --all
Plugin 'valloric/youcompleteme'           " autocomplete

" git
Plugin 'tpope/vim-fugitive'               " use git in vim within vim-airline
Plugin 'airblade/vim-gitgutter'           " show git diff

" language
Plugin 'fatih/vim-go'                     " golang

call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on





""" onehalfdark
color onehalfdark

""" airline
let g:airline_theme='onehalfdark'

""" nerdtree
" ne -> run nerd tree
nmap ne :NERDTreeToggle<CR>
" arrow synbols
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

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

""" youcompleteme
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1