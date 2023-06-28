let g:ipy_perform_mappings = 0
let g:ipy_completefunc = 'global'
let g:ipy_monitor_subchannel = 1

function! IPythonDBTRPC(...)
    vnew
    set filetype=python
    execute "JupyterConnect"
    close!

    let timeout = reltimefloat(reltime()) + 2.0
    while !IPythonConnected() && reltimefloat(reltime()) < timeout
        sleep 100m
    endwhile

    call SendText("%load_ext dbt-ipy")
    if index(a:000, "--existing") != -1
        call SendText("%dbt rpc " . join(a:000, " "), 1)
    endif
    set filetype=sql.jinja
endfunction

" Run text passed as parameter or use current selection
function! IPythonRunLines(...) range
    if a:0 < 1
        " this would mean there was already selected text
        " run the selected lines removing unnecesary indent
        execute "normal \<Plug>(JupyterRunVisual)"
    else
        let lines = a:1
        silent call jupyter#SendCode(lines)
    endif
    sleep 500m
    " can only refresh IPython buffer if not range selected
endfunction

function! IPythonConnected()
    py3 vim.command('let g:ipy_connected = {}'.format(int(_jupyter_session.kernel_client.check_connection())))
    return g:ipy_connected == 1
endfunction

command! -nargs=* IPythonDBTRPC call IPythonDBTRPC(<f-args>)
