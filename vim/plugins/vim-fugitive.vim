augroup fugitive_config
  autocmd!
  autocmd BufReadPost fugitive://* set bufhidden=delete
  autocmd BufWinEnter */COMMIT_EDITMSG call setline(1, FugitiveHead() . ": ")
augroup END
