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

function! GetPreviewWindowId()
    for tab_num in range(1, tabpagenr('$'))
        for win_num in range(1, winnr('$'))
            if gettabwinvar(tab_num, win_num, "&pvw") == 1
                return win_getid(win_num, tab_num)
            endif  
        endfor
    endfor
    return 0
endfunction

function! IsPythonKernelConnected()
    if exists("*IsJupyterConnected")
        return IsJupyterConnected()
    else
        return 0
    endif
endfunction

function! SendText(...)
    let l:text = get(a:, 1, "")
    let l:ignore_slime_affixes = get(a:, 2, get(g:, "ignore_slime_affixes", 0))

    let l:slime_preffix = exists("b:slime_preffix_suffix") ? b:slime_preffix_suffix[0] : ""
    let l:slime_suffix = exists("b:slime_preffix_suffix") ? b:slime_preffix_suffix[1] : ""

    let l:ipython_connected = 0
    " this should work for python and also filetype sql and sql.jinja
    if &filetype == "python" || index(split(&filetype, "\\."), "sql") != -1
        let l:ipython_connected = IsPythonKernelConnected()
    end

    " run it in either IPython, terminal or vimux
    if l:ipython_connected
        if !l:ignore_slime_affixes
            let l:text = l:slime_preffix . l:text . l:slime_suffix
        endif
        if &filetype == "sql"
            silent! wincmd P
            call call(function("JupyterRunLines"), [l:text])
            silent! wincmd p
        else
            call call(function("JupyterRunLines"), [l:text])
        endif
    elseif HasTermOpen()
        if &filetype == "scala" && !l:ignore_slime_affixes
            call VimTermSlime(l:slime_preffix, 0)
            call VimTermSlime(l:text)
            call VimTermSlime(l:slime_suffix, 0)
        else
            call VimTermSlime(l:text)
        endif
    elseif HasVimuxOpen()
        if &filetype == "scala" && !l:ignore_slime_affixes
            call VimuxSlime(l:slime_preffix, 0)
            call VimuxSlime(l:text)
            call VimuxSlime(l:slime_suffix, 0)
        else
            call VimuxSlime(l:text)
        endif
    else
        echo('You need to connect to a Python kernel, open a terminal buffer or open a vimux runner pane/window')
    endif
endfunction

function! VimSlimePrompt(...)
    let l:prompt = get(a:, 1, "")
    let l:ignore_slime_affixes = get(a:, 2, 0)

    call inputsave()
    let l:input_text = input(l:prompt)
    call inputrestore()

    call SendText(l:input_text, l:ignore_slime_affixes)
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
        call SendText(GetSelectedText(l:dedent), &ft=="scala" ? 1 : 0)
    elseif l:mode == "cell"
        execute "normal Vic"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == "query-i"
        execute "normal viq"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == "query-a"
        execute "normal Vaq"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == "paragraph"
        execute "normal! Vip"
        call SendText(GetSelectedText(l:dedent))
    elseif l:mode == "file"
        execute "normal! ggVG"
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
