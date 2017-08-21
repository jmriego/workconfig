call textobj#user#plugin('pythoncell', {
    \ '-': {
    \     '*sfile*': expand('<sfile>:p'),
    \     'select-a': 'ac',  '*select-a-function*': 's:select_a',
    \     'select-i': 'ic',  '*select-i-function*': 's:select_i',
    \ }})

function! s:select_a()
    return s:python_cell_object('a')
endfunction

function! s:select_i()
    return s:python_cell_object('i')
endfunction

" Search next cell marker (line starting with ##)
" par1 : b for searching back, any other thing for searching forward
" [par2] : if 1, it will only move there if there is no source code before it
function! s:search_cell_marker(...)
    let cell_marker_re = '^\(##\|# <[a-z]*cell>\)'
    let source_code_re = '^\s*[^\s#]'
    let search_option = a:1 ==? 'b' ? 'bc' : 'c'
    let only_through_no_code = a:0 > 1 ? 1 : 0

    let pos_cursor = getcurpos() " Save cursor position for restoring later

    if search(cell_marker_re, search_option) > 0
        let next_cell_marker = getcurpos()
    else
        " If no marker found in that direction return an empty position
        return []
    endif

    " If second parameter is set, search for some code before the marker
    if only_through_no_code == 1
        call setpos('.', pos_cursor)
        " If we find some source code before the line of the cell marker
        if search(source_code_re, search_option, next_cell_marker[1]) > 0
            let next_cell_marker = []
        endif
    endif

    call setpos('.', pos_cursor) " Restore the cursor position
    return next_cell_marker
endfunction


" If we are in an empty cell, we will increase the selection range
function! s:python_cell_object(object_type)
    let prev_marker = s:search_cell_marker('b')
    " if we find it, the next line would be the start
    if len(prev_marker) > 0
        call setpos('.', prev_marker)
    endif
    let pos_current = getcurpos()
    normal! 0

    while 1==1
        let possible = s:search_cell_marker('b', 1)
        " Is there another marker above with no code before it?
        if len(possible)>0
            let expanded_up = possible
            call setpos('.', possible)
        else
            break
        endif

        if line('.') > 1
            normal! k$
        else
            break
        endif
    endwhile

    call setpos('.', pos_current)
    normal! 0

    while 1==1
        let possible = s:search_cell_marker('f', 1)
        " Is there another marker below with no code before it?
        if len(possible)>0
            let expanded_down = possible
            call setpos('.', possible)
        else
            break
        endif

        if line('.') < line('$')
            normal! j0
        else
            break
        endif
    endwhile

    " Am I between two cell markers with no code inside?
    if exists("expanded_up") && exists("expanded_down")
        " Go to the line after the empty cell
        call setpos('.', expanded_down)
        if line('.') < line('$')
            normal! j0
        endif
        " If object (ic), the line after the empty cell is the start
        if a:object_type ==? 'i'
            let start_selection = getcurpos()
        else
            " If object ac, the start is the expanded up cell
            let start_selection = expanded_up
        endif
    else
        " if we found a previous cell marker, the next line would be the start
        if len(prev_marker) > 0
            call setpos('.', prev_marker)
            if line('.') < line('$')
                normal! j0
            endif
        else
            normal! gg
        endif
        let start_selection = getcurpos()
    endif

    let next_marker = s:search_cell_marker('f')
    if len(next_marker) > 0
        call setpos('.', next_marker)
        if line('.') > 1
            normal! k$
        endif
    else
        normal! G$
    endif
    let end_selection = getcurpos()

    return ['V', start_selection, end_selection]
endfunction


function! GotoPreviousCell()
    let start_current_cell = s:python_cell_object('a')[1]
    call setpos('.', [0, start_current_cell[1]-1, 1, 0])
    let start_previous_cell = s:python_cell_object('i')[1]
    call setpos('.', [0, start_previous_cell[1], 1, 0])
endfunction

function! GotoNextCell()
    let end_current_cell = s:python_cell_object('a')[2]
    call setpos('.', [0, end_current_cell[1]+1, 1, 0])
    if line('.') < line('$')
        let start_next_cell = s:python_cell_object('i')[1]
        call setpos('.', [0, start_next_cell[1], 1, 0])
    endif
endfunction
