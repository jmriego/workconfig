set cursorline

let g:buffer_entered_at = 0.0

function! s:cursorMoved()
  if reltimefloat(reltime()) > g:buffer_entered_at + 0.1
    echo g:buffer_entered_at
    set nocursorline
    autocmd! mycursorline CursorMoved *
  endif
endfunction

augroup mycursorline
  autocmd!
  autocmd CursorHold,BufLeave,BufEnter * set cursorline
  autocmd BufEnter * let g:buffer_entered_at = reltimefloat(reltime())
  autocmd CursorHold,BufEnter *
      \ autocmd CursorMoved * call s:cursorMoved()
  autocmd CursorMoved * call s:cursorMoved()
augroup end
