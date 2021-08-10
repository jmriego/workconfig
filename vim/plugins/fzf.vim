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

func! ChooseCtrlPFunc()
    if exists('b:git_dir')
        " return "GFiles " . fnamemodify(b:git_dir, ':h')
        let git_dir = trim(system("git -C '" . substitute(b:git_dir, "/\.git$", "", "") . "' rev-parse --show-toplevel"))
        return "call fzf#vim#gitfiles('', fzf#vim#with_preview({ 'dir': '" . git_dir . "' }), 0)"

    elseif haslocaldir()
        return "Files " . expand('%:p:h')
    else
        return "Files"
    endif
endfunc
