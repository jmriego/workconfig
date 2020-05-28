augroup my_projections
    autocmd!
    autocmd User ProjectionistActivate call s:run_projections()
augroup END

function! s:run_projections() abort
    for [root, value] in projectionist#query('autoread')
        if value == "true"
            setlocal autoread
        endif
        break
    endfor
    for [root, value] in projectionist#query('suffixesadd')
        for ext in value
        execute 'setlocal suffixesadd+=' . ext
        endfor
        break
    endfor
endfunction
