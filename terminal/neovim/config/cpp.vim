" set tab size to 4
set ts=4
set shiftwidth=4

" Compile
" %:p:h -> directory containing file ('head')
" nmap <F7> :w<ENTER>:make -cp %:p:h -d %:p:h %<ENTER>
nmap <F7> :w<ENTER>:!g++ % -std=c++11 -o $TMPDIR/algorithm-test<ENTER>

" Run
" %:t:r -> tail:name of file less one extension
nmap <C-l> :w<ENTER>:!g++ % -std=c++11 -o $TMPDIR/algorithm-test && $TMPDIR/algorithm-test<ENTER>
