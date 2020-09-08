let g:fzf_buffers_jump = 1

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Type'],
  \ 'fg+':     ['fg', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Type'],
  \ 'info':    ['fg', 'Identifier'],
  \ 'prompt':  ['fg', 'Constant'],
  \ 'pointer': ['fg', 'Constant'],
  \ 'marker':  ['fg', 'Constant'],
  \ 'spinner': ['fg', 'Identifier'],
  \ 'header':  ['fg', 'Statement'] }

function! s:ag_with_opts(arg, bang)
  let tokens  = split(a:arg)
  let ag_opts = join(filter(copy(tokens), 'v:val =~ "^-"'))
  let query   = join(filter(copy(tokens), 'v:val !~ "^-"'))
  call fzf#vim#ag_raw(ag_opts . " " . query, a:bang)
endfunction

autocmd VimEnter * command! -nargs=* -bang Ag call s:ag_with_opts(<q-args>, <bang>0)
