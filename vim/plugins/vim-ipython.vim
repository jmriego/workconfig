let g:ipy_perform_mappings = 0
let g:ipy_completefunc = 'global'
let g:ipy_monitor_subchannel = 1

function! IPythonDBTRPC(...)
    vnew
    set filetype=python
    execute "IPython"
    close!

    try
        silent! wincmd P
    catch /^Vim\%((\a\+)\)\=:E441/
        silent pedit
        silent! wincmd P
    endtry
    if expand("%") != 'vim-ipython'
        pcl
        silent pedit +set\ ma vim-ipython
        silent! wincmd P
        set filetype=python
    endif

    call SendText("%load_ext dbt-ipy")
    if index(a:000, "--existing") != -1
        call SendText("%dbt rpc" . join(a:000, " "))
    endif

    silent! wincmd p
endfunction

" Run text passed as parameter or use current selection
function! IPythonRunLines(...) range
    if a:0 < 1
        " this would mean there was already selected text
        " run the selected lines removing unnecesary indent
        execute "normal \<Plug>(IPython-RunLines)"
    else
        let lines = a:1
        silent Python2or3 run_command(vim.eval('lines'))
    endif
    sleep 500m
    " can only refresh IPython buffer if not range selected
    execute "normal! \<Esc>"
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

command! -nargs=* IPythonDBTRPC call IPythonDBTRPC()
