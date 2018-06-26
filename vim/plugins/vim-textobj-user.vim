" Create cell text objects which are regions of text delimited by
" lines starting with ##
exec 'source ' . expand('<sfile>:h') . '/../python_cell_userobj.vim'
nnoremap <expr> <silent> [c &diff ? '[c' : ':call GotoPreviousCell()<CR>'
nnoremap <expr> <silent> ]c &diff ? ']c' : ':call GotoNextCell()<CR>'
