" Create cell text objects which are regions of text delimited by
" lines starting with ##
augroup textobj_user
    autocmd!
    autocmd VimEnter * exec 'source ' . expand('<sfile>:h') . '/../python_cell_userobj.vim'
    autocmd VimEnter * exec 'source ' . expand('<sfile>:h') . '/../sql_query_userobj.vim'
augroup END
