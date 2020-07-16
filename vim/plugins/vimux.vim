let g:VimuxUseNearest = 0

" Run selected range through vimux
"  It accepts a parameter with the text to send
function! VimuxSlime(...) range
    let l:text = get(a:, 1, "")
    let g:include_enter = get(a:, 2, 1)

    call VimuxSendText(l:text)
    if g:include_enter == 1 && l:text !~ '\n$'
        call VimuxSendKeys("Enter")
    endif
endfunction

function! HasVimuxOpen()
    return exists("g:VimuxRunnerIndex")
endfunction

function! VimuxReusePrevious()
    call _VimuxTmux("last-"._VimuxRunnerType())
    let g:VimuxRunnerIndex = _VimuxTmuxIndex()
    call _VimuxTmux("last-"._VimuxRunnerType())
endfunction
