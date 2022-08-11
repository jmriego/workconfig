function! s:replace_commit_msg()
  if getline(1) == ""
    call setline(1, FugitiveHead() . ": ")
  endif
endfunction

function! s:ftplugin_fugitive() abort
  nnoremap <buffer> <silent> cc :Git commit --quiet<CR>
  nnoremap <buffer> <silent> ca :Git commit --quiet --amend<CR>
  nnoremap <buffer> <silent> ce :Git commit --quiet --amend --no-edit<CR>
endfunction

augroup fugitive_config
  autocmd!
  autocmd BufReadPost fugitive://* set bufhidden=delete
  autocmd BufWinEnter */COMMIT_EDITMSG call s:replace_commit_msg()
  autocmd FileType fugitive call s:ftplugin_fugitive()
augroup END
