call textobj#user#plugin('pythoncell', {
    \ '-': {
    \     '*sfile*': expand('<sfile>:p'),
    \     'select-a': 'ac',  '*select-a-function*': 's:cell_select_a',
    \     'select-i': 'ic',  '*select-i-function*': 's:cell_select_i',
    \  },
    \ 'class': {
    \     '*sfile*': expand('<sfile>:p'),
    \     'select-a': 'apc',
    \     'select-i': 'ipc',
    \     'select-a-function': 's:class_select_a',
    \     'select-i-function': 's:class_select_i',
    \     'pattern': '^\s*\zsclass \(.\|\n\)\{-}:',
    \     'move-p': '<buffer>[pc',
    \     'move-n': '<buffer>]pc',
    \  },
    \ 'function': {
    \     '*sfile*': expand('<sfile>:p'),
    \     'select-a': 'af',
    \     'select-i': 'if',
    \     'select-a-function': 's:function_select_a',
    \     'select-i-function': 's:function_select_i',
    \     'pattern': '^\s*\zs\(def\|async def\) \(.\|\n\)\{-}:',
    \     'move-p': '<buffer>[pf',
    \     'move-n': '<buffer>]pf',
    \  },
    \ })

function! s:cell_select_a()
    return s:python_cell_object('a')
endfunction

function! s:cell_select_i()
    return s:python_cell_object('i')
endfunction

function! s:line_of_pos(pos)
    return a:pos[1]
endfunction

" Search next cell marker (line starting with ##)
" par1 : b for searching back, any other thing for searching forward
" [par2] : if 1, it will only move there if there is no source code before it
function! s:search_cell_marker(...)
    let simple_header_re = '\_^##.*'
    let notebook_header_re = '\_^# <[a-z]*cell>.*'
    let big_header_re = '\_^##.*\n\(\s*\(#.*\)\=\n\)*##.*'
    let source_code_re = '^\s*[^\s#]'
    let search_option = a:1 ==? 'b' ? 'bc' : 'c'

    let pos_cursor = getcurpos() " Save cursor position for restoring later

    let any_header_re = '\(' . simple_header_re . '\|' . notebook_header_re . '\)'
    if search(any_header_re, search_option) > 0
        let found_cell_marker = [line('.'), line('.')]
        if getline('.') =~ simple_header_re
            " Check if it's inside a bigger header
            let reverse_search_option = search_option =~ 'b' ? 'c' : 'bc'
            let next_line_code = search(source_code_re, reverse_search_option)
            if !next_line_code > 0
                if reverse_search_option =~ 'b'
                    normal! gg
                else
                    normal! G$
                endif
            endif
            let start_big_header = search(big_header_re, search_option)
            call cursor(next_line_code, 1) " Restore the cursor position
            let end_big_header = search(big_header_re, search_option . 'e')
            if found_cell_marker[0] >= min([start_big_header, end_big_header])
                \ && found_cell_marker[0] <= max([start_big_header, end_big_header])
                let found_cell_marker = [min([start_big_header, end_big_header])
                        \ , max([start_big_header, end_big_header])]
            endif
        endif
    else
        " If no marker found in that direction return an empty position
        return []
    endif

    call setpos('.', pos_cursor) " Restore the cursor position
    return found_cell_marker
endfunction

" If we are in an empty cell, we will increase the selection range
function! s:python_cell_object(object_type)
    let prev_marker = s:search_cell_marker('b')
    " if we find it, the next line would be the start
    if len(prev_marker) > 0
        if a:object_type ==? 'a'
            call cursor(prev_marker[0], 1)
            let start_selection = getcurpos()
            call cursor(prev_marker[1] + 1, 1)
            if line('$') <= prev_marker[1]
                let end_selection = getcurpos()
                return ['V', start_selection, end_selection]
            endif
        else
            if line('$') > prev_marker[1]
                call cursor(prev_marker[1] + 1, 1)
                let start_selection = getcurpos()
            else
                return 0
            endif
        endif
        call cursor(prev_marker[1] + 1, 1)
    else
        call cursor(1, 1)
        let start_selection = getcurpos()
    endif

    let next_marker = s:search_cell_marker('')
    if len(next_marker) > 0
        call cursor(next_marker[1]-1, 1)
        let end_selection = getcurpos()
    else
        call cursor(line('$'), 1)
        let end_selection = getcurpos()
    endif

    return ['V', start_selection, end_selection]
endfunction

function! g:PythonCellObject(object_type)
    call s:python_cell_object(a:object_type)
endfunction

function! s:scroll_show(numline)
    if line("w0") > a:numline
        let zt_line = a:numline
        let i = 1
        while i <= &scrolloff
            let zt_line = zt_line + 1
            if foldclosedend(zt_line) > 0
                let zt_line = foldclosedend(zt_line)
            endif
            let i = i + 1
        endwhile
        if zt_line > 0
            execute "normal! " . zt_line . "zt"
        endif
    elseif line("w$") < a:numline
        let zb_line = a:numline
        let i = 1
        while i <= &scrolloff
            let zb_line = zb_line - 1
            if foldclosed(zb_line) > 0
                let zb_line = foldclosed(zb_line)
            endif
            let i = i + 1
        endwhile
        if zb_line > 0
            execute "normal! " . zb_line . "zb"
        endif
    endif
endfunction

function! GotoPreviousCell()
    let start_current_cell = s:python_cell_object('a')[1]
    let end_previous_cell = [0, s:line_of_pos(start_current_cell)-1, 1, 0]
    call s:scroll_show(s:line_of_pos(end_previous_cell))
    call setpos('.', end_previous_cell)

    let header_previous_cell = s:python_cell_object('a')[1]
    call s:scroll_show(s:line_of_pos(header_previous_cell))

    let start_previous_cell = s:python_cell_object('i')[1]
    call setpos('.', start_previous_cell)
    execute "normal! ". s:line_of_pos(start_previous_cell) ."G"
endfunction

function! GotoNextCell()
    let end_current_cell = s:python_cell_object('a')[2]
    let start_next_cell = [0, s:line_of_pos(end_current_cell)+1, 1, 0]
    call s:scroll_show(s:line_of_pos(start_next_cell))
    call setpos('.', start_next_cell)

    let end_next_cell = s:python_cell_object('a')[2]
    call s:scroll_show(s:line_of_pos(end_next_cell))

    let start_next_cell = s:python_cell_object('i')[1]
    call setpos('.', start_next_cell)
    execute "normal! ". s:line_of_pos(start_next_cell) ."G"
endfunction

function! s:move_cursor_to_starting_line()
    " Start at a nonblank line
    let l:cur_pos = getpos('.')
    let l:cur_line = getline('.')
    if l:cur_line =~# '^\s*$'
        call cursor(prevnonblank(l:cur_pos[1]), 0)
    endif
endfunction

function! s:find_defn_line(kwd)
    " Find the defn line
    let l:cur_line = getline('.')
    while l:cur_line =~# '^\s*@'
        normal! j
        let l:cur_line = getline('.')
    endwhile
    let l:cur_pos = getpos('.')
    if l:cur_line =~# '^\s*'.a:kwd.' '
        let l:defn_pos = l:cur_pos
    else
        let l:cur_indent = indent(l:cur_pos[1])
        while 1
            if search('^\s*'.a:kwd.' ', 'bW')
                let l:defn_pos = getpos('.')
                let l:defn_indent = indent(l:defn_pos[1])
                if l:defn_indent >= l:cur_indent
                    " This is a defn at the same level or deeper, keep searching
                    continue
                else
                    " Found a defn, make sure there aren't any statements at a
                    " shallower indent level in between
                    for l:l in range(l:defn_pos[1] + 1, l:cur_pos[1])
                        if getline(l:l) !~# '^\s*$' && indent(l:l) <= l:defn_indent
                            throw "defn-not-found"
                        endif
                    endfor
                    break
                endif
            else
                " We didn't find a suitable defn
                throw "defn-not-found"
            endif
        endwhile
    endif
    call cursor(defn_pos)
    return l:defn_pos
endfunction

function! s:find_prev_decorators(l)
    " Find the line with the first (valid) decorator above `line`, return the
    " current line, if there is none.
    let linenr = a:l
    while 1
        let prev = prevnonblank(linenr-1)
        if prev == 0 || prev != linenr-1
            " Line is not above current one.
            break
        endif
        let prev_indent = indent(prev)
        if prev_indent != indent(linenr)
            " Line is not indented the same.
            break
        endif
        if getline(prev)[prev_indent] != "@"
            break
        endif
        let linenr = prev
    endwhile
    return linenr
endfunction

function! s:find_last_line(kwd, defn_pos, indent_level)
    " Find the last line of the block at given indent level
    let l:cur_pos = getpos('.')
    let l:end_pos = l:cur_pos
    while 1
        " Is this a one-liner?
        if getline('.') =~# '^\s*'.a:kwd.'\[^:\]\+:\s*\[^#\]'
            return a:defn_pos
        endif
        " This isn't a one-liner, so skip the def line
        if line('.') == a:defn_pos[1]
            normal! j
            continue
        endif
        if getline('.') !~# '^\s*$'
            if indent('.') > a:indent_level
                let l:end_pos = getpos('.')
            else
                break
            endif
        endif
        if line('.') == line('$')
            break
        else
            normal! j
        endif
    endwhile
    call cursor(l:cur_pos[1], l:cur_pos[2])
    return l:end_pos
endfunction

function! s:find_defn(kwd)
    call s:move_cursor_to_starting_line()

    try
        let l:defn_pos = s:find_defn_line(a:kwd)
    catch /defn-not-found/
        return 0
    endtry
    let l:defn_indent_level = indent(l:defn_pos[1])

    let l:end_pos = s:find_last_line(a:kwd, l:defn_pos, l:defn_indent_level)
    return ['V', l:defn_pos, l:end_pos]
endfunction

function! s:select_a(kwd)
    let l:defn_pos = s:find_defn(a:kwd)
    if type(l:defn_pos) == type([])
        let l:defn_pos[1][1] = s:find_prev_decorators(l:defn_pos[1][1])
        return l:defn_pos
    endif
    return 0
endfunction

function! s:select_i(kwd)
    let l:a_pos = s:find_defn(a:kwd)
    if type(l:a_pos) == type([])
        if l:a_pos[1][1] == l:a_pos[2][1]
            " This is a one-liner, treat it like af
            " TODO Maybe change this to a 'v'-mode selection and only get the
            " statement from the one-liner?
            return l:a_pos
        endif
        " Put the cursor on the def line
        call cursor(l:a_pos[1][1], l:a_pos[1][2])
        " Get to the closing parenthesis if it exists
        normal! ^f(%
        " Start from the beginning of the next line
        normal! j0
        let l:start_pos = getpos('.')
        return ['V', l:start_pos, l:a_pos[2]]
    endif
    return 0
endfunction

function! s:class_select_a()
    return s:select_a('class')
endfunction

function! s:class_select_i()
    return s:select_i('class')
endfunction

function! s:function_select_a()
    return s:select_a('\(async def\|def\)')
endfunction

function! s:function_select_i()
    return s:select_i('\(async def\|def\)')
endfunction

function! s:function_select(object_type)
  return s:function_select_{a:object_type}()
endfunction
