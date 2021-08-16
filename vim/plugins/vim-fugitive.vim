function! s:replace_commit_msg()
  if getline(1) == ""
    call setline(1, FugitiveHead() . ": ")
  endif
endfunction

augroup fugitive_config
  autocmd!
  autocmd BufReadPost fugitive://* set bufhidden=delete
  autocmd BufWinEnter */COMMIT_EDITMSG call s:replace_commit_msg()
augroup END
