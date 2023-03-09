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

command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '
  \ .(substitute(<q-args>, "^$", expand("<cword>"), "")), 1,
  \   fzf#vim#with_preview(), <bang>0)

command! -bang -nargs=* Ag
  \ call fzf#vim#ag_raw(
  \   (substitute(<q-args>, "^$", expand("<cword>"), "")),
  \   fzf#vim#with_preview(), <bang>0)

func! ChooseCtrlPFunc()
    if exists('b:git_dir') && b:git_dir != ""
        " return "GFiles " . fnamemodify(b:git_dir, ':h')
        let git_dir = trim(system("git -C '" . substitute(b:git_dir, "/\.git$", "", "") . "' rev-parse --show-toplevel"))
        return "call fzf#vim#gitfiles('', fzf#vim#with_preview({ 'dir': '" . git_dir . "' }), 0)"
    elseif haslocaldir()
        return "Files " . expand('%:p:h')
    elseif expand("%") == "" && isdirectory(".git")
        return "call fzf#vim#gitfiles('', fzf#vim#with_preview(), 0)"
    else
        return "Files"
    endif
endfunc

function! s:get_quickfix_urls(...)
  let l:strings = []
  let l:url_regex = 'https\?:\/\/\(www\.\)\?[-a-zA-Z0-9@:%._\+~#=]\{2,256}\.[a-z]\{2,4}\>\([-a-zA-Z0-9@:%_\+.~#?&//=]*\)'
  for line in getqflist()
      call substitute(line['text'], l:url_regex, '\=add(l:strings, submatch(0))', 'g')
  endfor
  return fzf#vim#_uniq(sort(l:strings))
endfunction

function! s:open_url(url)
  call system('xdg-open "' . a:url . '"')
endfunction

function! ChooseOpenURL()
  call fzf#run({
    \ 'source': s:get_quickfix_urls(),
    \ 'sink': function('s:open_url'),
    \ 'options': '--select-1 --margin 15%,0' })
endfunction

function! s:git_list_branches(typed, ...)
  let branches = systemlist('git branch | cut -c 3-')
  if empty(a:typed)
    return branches
  endif
  return filter(branches, { idx, val -> stridx(val, a:typed) >= 0 })
endfunction

function! s:git_diff_branch(branch)
  let branch = len(a:branch) ? a:branch : 'master'
  let source = 'git diff --name-status ' .. branch
  let preview = 'git diff --color=always ' .. branch .. ' -- {-1}'
  let spec = { 'source': source, 'options': ['--preview', preview] }
  function spec.sink(match)
    execute 'e' split(a:match, "\t")[-1]
  endfunction

  call fzf#run(fzf#wrap(spec))
endfunction

command! -nargs=? -complete=customlist,s:git_list_branches GDiffBranch call s:git_diff_branch(<q-args>)
