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

function! IsPythonKernelConnected()
    if &filetype == "python" && exists("*IPythonConnected")
        return IPythonConnected()
    else
        return 0
    endif
endfunction

function! SendText(...)
    let l:ipython_connected = IsPythonKernelConnected()
    let l:text = get(a:, 1, "")
    let l:scala_paste_mode = get(a:, 2, get(g:, "scala_paste_mode", 0))

    " run it in either IPython, terminal or vimux
    if l:ipython_connected
        call call(function("IPythonRunLines"), l:text)
    elseif HasTermOpen()
        if &filetype == "scala" && !l:scala_paste_mode
            call VimTermSlime(":paste")
            call VimTermSlime(l:text)
            call VimTermSlime("C-d", 0)
        else
            call VimTermSlime(l:text)
        endif
    elseif HasVimuxOpen()
        if &filetype == "scala" && !l:scala_paste_mode
            call VimuxSlime(":paste")
            call VimuxSlime(l:text)
            call VimuxSlime("C-d", 0)
        else
            call VimuxSlime(l:text)
        endif
    else
        echo('You need to connect to a Python kernel, open a terminal buffer or open a vimux runner pane/window')
    endif
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

    let l:ipython_connected = IsPythonKernelConnected()

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
        call SendText(GetSelectedText(l:dedent), 1)
    elseif l:mode == "cell"
        execute "normal Vic"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == "paragraph"
        execute "normal! Vip"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == ""
        call SendText(GetSelectedText(l:dedent, "gv"))
    else
        " this is in case the mode contains text such as "vip\<C-v>$o^"
        let l:select_command = substitute(l:mode, '\(<[A-Za-z-()^$]*>\)', '\\\1', 'g')
        execute "normal! " . l:select_command
        call SendText(GetSelectedText(l:dedent))
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
endfunction
