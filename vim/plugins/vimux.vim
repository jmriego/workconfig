let g:VimuxUseNearest = 0

" Run selected range through vimux
"  It accepts a parameter with the text to send
function! VimuxSlime(text) range
    call VimuxSendText(a:text)
    if a:text !~ '\n$'
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
