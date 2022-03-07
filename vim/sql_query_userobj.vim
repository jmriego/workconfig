call textobj#user#plugin('sql', {
\   'query': {
\     '*sfile*': expand('<sfile>:p'),
\     'select-a': 'aq',  '*select-a-function*': 's:query_select_a',
\     'select-i': 'iq',  '*select-i-function*': 's:query_select_i',
\   },
\ })

let s:query_limit_re = ';\s*$'

function! s:query_select_i()
    " search for the nearest select statement
    " we start by moving forward to the end of the current query
    " by going to the parenthesis close or semicolon
    if searchpair('(', '', ')', '') <= 0
        call search(s:query_limit_re, 'c')
    endif
    call search('select\c', 'bc')
    call searchpair('(', 'with\c', ')', 'bc')
    call search('\(select\|with\)\c', 'c')
    let query_start = getcurpos() " Save cursor position for restoring later

    " if the query doesn't end in parenthesis
    if searchpair('(', '', ')', '') <= 0
        if search(s:query_limit_re, 'c') <=0
            call cursor(line('$'), col([line('$'), '$']))
        endif
        call search('[^;]', 'bc')
    else
        call search('[^;\s]', 'b')
    endif
    let query_end = getcurpos() " Save cursor position for restoring later
    return ['v', query_start, query_end]
endfunction

function! s:query_select_a()
    " if we find it, the next line would be the start
    if search(s:query_limit_re, 'bc') > 0
        " select i cell
        if line('$') > line('.')
            call cursor(line('.') + 1, 1)
        endif
    else
        " no previous marker found. select to start of file
        call cursor(1, 1)
    endif
    let start_selection = getcurpos()

    " end of the current cell
    if search(s:query_limit_re, 'c') > 0
        " line of next cell marker
    else
        " no next cell found. end at end of file
        call cursor(line('$'), 1)
    endif
    let end_selection = getcurpos()

    return ['V', start_selection, end_selection]
endfunction
