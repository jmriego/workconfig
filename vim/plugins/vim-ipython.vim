let g:ipy_perform_mappings = 0
let g:ipy_completefunc = 'global'
let g:ipy_monitor_subchannel = 1

" Run selected text or select python cell and run it
"  It accepts a parameter with the keys to press to make a selection
function! IPythonRunLines(...) range
    let select_command = a:0 < 1 ? '' : substitute(a:1, '\(<[A-Za-z-()]*>\)', '\\\1', 'g')
    let winview = winsaveview()
    if select_command == ""
        " this would mean there was already selected text
        " run the selected lines removing unnecesary indent
        let lines = split(GetSelectedText("gv"), '\n')
        let dedented_lines = []
        for line in lines
            if !exists('first_line_indent') || first_line_indent < 0
                let first_line_indent = match(line, '\S')
            endif
            if first_line_indent >= 0
                call add(dedented_lines, strpart(line, first_line_indent))
            endif
        endfor
        silent Python2or3 run_command('\n'.join(vim.eval('dedented_lines')))
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
        execute "normal \<Plug>(IPython-RunLines)"
        " restore previous visual selection
        if prev_visual_mode != ""
            execute "normal! \<Esc>"
            execute "normal " . prev_visual_mode
            execute "normal! \<Esc>"
            call setpos("'<", prev_left_visual)
            call setpos("'>", prev_right_visual)
            execute "normal! gv"
        endif
    endif
    execute "normal! \<Esc>"
    call winrestview(winview)
    sleep 500m
    execute "normal \<Plug>(IPython-UpdateShell-Silent)"
endfunction

function! IPythonInputLoop()
    IPythonInput
    Python2or3 vim.command('let current_stdin_prompt = {}'.format(current_stdin_prompt))
endfunction

function! IPythonConnected()
    Python2or3 vim.command('let g:ipy_connected = {}'.format(1 if kc else 0))
    return g:ipy_connected
endfunction
