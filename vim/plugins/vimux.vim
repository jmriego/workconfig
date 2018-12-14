let g:VimuxUseNearest = 0
" Run selected range through vimux
"  It accepts a parameter with the keys to press to make a selection
function! VimuxSlime(...) range
    let select_command = a:0 < 1 ? '' : substitute(a:1, '\(<[A-Za-z-()^$]*>\)', '\\\1', 'g')
    let winview = winsaveview()
    if select_command == ""
        " this would mean there was already selected text
        let s:selected_text = GetSelectedText("gv")
    else
        " save the current selection and go back to where we were
        normal! gv
        let prev_visual_mode = visualmode()
        let prev_left_visual = getpos("'<")
        let prev_right_visual = getpos("'>")
        execute "normal! \<Esc>"
        call winrestview(winview)
        " make a selection with the specified keys
        execute "normal " . select_command
        let s:selected_text = GetSelectedText()
        " restore previous visual selection
        if prev_visual_mode != ""
            execute "normal " . prev_visual_mode
            execute "normal! \<Esc>"
            call setpos("'<", prev_left_visual)
            call setpos("'>", prev_right_visual)
            execute "normal! gv"
        endif
    endif
    execute "normal! \<Esc>"
    call VimuxSendText(s:selected_text)
    if s:selected_text !~ '\n$'
        call VimuxSendKeys("Enter")
    endif

    call winrestview(winview)
endfunction

function! VimuxReusePrevious()
    call _VimuxTmux("last-"._VimuxRunnerType())
    let g:VimuxRunnerIndex = _VimuxTmuxIndex()
    call _VimuxTmux("last-"._VimuxRunnerType())
endfunction
