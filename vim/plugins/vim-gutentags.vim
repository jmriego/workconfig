if isdirectory(expand('~/vimfiles/tags'))
    let g:gutentags_cache_dir = expand('~/vimfiles/tags')
else
    let g:gutentags_cache_dir = expand('~/.vim/tags')
endif

silent! call mkdir(g:gutentags_cache_dir, 'p')
