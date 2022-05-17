" Compile
" %:p:h -> directory containing file ('head')
" nmap <F7> :w<ENTER>:make -cp %:p:h -d %:p:h %<ENTER>
nmap <F7> :w<ENTER>:!g++ % -o /tmp/algorithm-test<ENTER>

" Run
" %:t:r -> tail:name of file less one extension
nmap <F11> :w<ENTER>:!g++ % -o /tmp/algorithm-test && /tmp/algorithm-test<ENTER>
