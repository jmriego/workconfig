function! SavePreviousSelection() range
    let l:winview = winsaveview()
    normal! gv
    let l:prev_visual_mode = visualmode()
    let l:prev_left_visual = getpos("'<")
    let l:prev_right_visual = getpos("'>")
    execute "normal! \<Esc>"
    let result = {
                \ "winview":  l:winview,
                \ "prev_visual_mode":  l:prev_visual_mode,
                \ "prev_left_visual":  l:prev_left_visual,
                \ "prev_right_visual": l:prev_right_visual}
    " This function has the side effect of moving the cursor to the previous
    " selection. Restore previous cursor position
    call winrestview(l:winview)
    return result
endfunction

function! RestoreSelection(selection)
    if a:selection["prev_visual_mode"] != ""
        execute "normal! " . a:selection["prev_visual_mode"]
        execute "normal! \<Esc>"
        call setpos("'<", a:selection["prev_left_visual"])
        call setpos("'>", a:selection["prev_right_visual"])
        execute "normal! gv"
        execute "normal! \<Esc>"
    endif
    call winrestview(a:selection["winview"])
endfunction

function! VimTermSlime(text) range
    let l:terminal_buffer = term_list()[0]
    call term_sendkeys(l:terminal_buffer, a:text)
    if a:text !~ '\n$'
        let a:text .= '\n'
        call term_sendkeys(l:terminal_buffer, "\<cr>")
    endif
    sleep 500m
    call term_wait(l:terminal_buffer)
endfunction

function! HasTermOpen()
    return len(term_list()) > 0
endfunction

" function to run some text through IPython, a terminal or a vimux pane/window
" parameter 1. mode: It accepts the following values
"   * line (current line)
"   * block (either a paragraph or a python cell if connected to a kernel)
"   * '' (empty for running current selection)
"   * Vip or some other command to select desired region of text
" parameter 2. advance: Whether to go to the next line/block after running
" parameter 3. dedent: Should we dedent the text. Default to dedent in python
function! VimSlime(...) range
    let l:mode = get(a:, 1, "")
    let l:advance = get(a:, 2, 0)
    let l:dedent = get(a:, 3, &filetype == "python")

    " save previous selection if we are going to make a new one
    if l:mode != ""
        let l:selection = SavePreviousSelection()
    endif

    if &filetype == "python" && exists("*IPythonConnected")
        let l:ipython_connected = IPythonConnected()
    else
        let l:ipython_connected = 0
    endif

    " block can either mean python cell or paragraph
    if l:mode == "block"
        if l:ipython_connected
            let l:mode = "cell"
        else
            let l:mode = "paragraph"
        endif
    endif

    " select the text if necessary and populate the variable with its content
    if l:mode == "line"
        execute "normal! V"
        let l:selected_text = GetSelectedText(l:dedent)
    elseif l:mode == "cell"
        execute "normal! Vic"
        let l:selected_text = GetSelectedText(l:dedent)
    elseif l:mode == "paragraph"
        execute "normal! Vip"
        let l:selected_text = GetSelectedText(l:dedent)
    elseif l:mode == ""
        let l:selected_text = GetSelectedText(l:dedent, "gv")
    else
        " this is in case the mode contains text such as "vip\<C-v>$o^"
        let l:select_command = substitute(l:mode, '\(<[A-Za-z-()^$]*>\)', '\\\1', 'g')
        execute "normal! " . l:select_command
        let l:selected_text = GetSelectedText(l:dedent)
    endif

    " run it in either IPython, terminal or vimux
    if l:ipython_connected
        if l:mode == ""
            call IPythonRunLines()
        else
            call IPythonRunLines(l:selected_text)
        endif
    elseif HasTermOpen()
        call VimTermSlime(l:selected_text)
    elseif HasVimuxOpen()
        call VimuxSlime(l:selected_text)
    else
        echo('You need to connect to a Python kernel, open a terminal buffer or open a vimux runner pane/window')
    endif

    " Deselect text and restore previous selection info
    execute "normal! \<Esc>"
    if l:mode != ""
        call RestoreSelection(l:selection)
    endif

    " Advance to the next line or block
    if l:advance
        if l:mode == "line"
            execute "normal! j"
        elseif l:mode == "cell"
            call GotoNextCell()
        elseif l:mode == "paragraph"
            execute "normal! })"
        elseif l:mode == ""
            execute "normal! j"
        endif
    endif
    let g:try = l:selected_text
endfunction
