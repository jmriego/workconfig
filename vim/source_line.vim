set cursorline

let g:just_entered_buffer = 1

function! s:cursorMoved()
  if g:just_entered_buffer <= 0
    set nocursorline
    autocmd! mycursorline CursorMoved *
  else
    let g:just_entered_buffer -= 1
  endif
endfunction

augroup mycursorline
  autocmd!
  autocmd CursorHold,BufLeave,BufEnter * set cursorline
  autocmd BufEnter * let g:just_entered_buffer = 1
  autocmd CursorHold,BufEnter *
      \ autocmd! mycursorline CursorMoved * call s:cursorMoved()
augroup end
