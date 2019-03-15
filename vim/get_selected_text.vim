let s:INT = { 'MAX': 2147483647 }

function! s:sort_pos(pos_list) abort
    " pos_list: [ [x1, y1], [x2, y2] ]
    return sort(a:pos_list, 's:compare_pos')
endfunction

function! s:curswant() abort
    return winsaveview().curswant
endfunction

" @return Boolean
function! s:is_exclusive() abort
    return &selection is# 'exclusive'
endfunction

" @return coordinate: [Number, Number]
function! s:getcoord(expr) abort
    return getpos(a:expr)[1:2]
endfunction

" 7.4.341
" http://ftp.vim.org/vim/patches/7.4/7.4.341
if v:version > 704 || v:version == 704 && has('patch341')
    function! s:sort_num(xs) abort
        return sort(a:xs, 'n')
    endfunction
else
    function! s:_sort_num_func(x, y) abort
        return a:x - a:y
    endfunction
    function! s:sort_num(xs) abort
        return sort(a:xs, 's:_sort_num_func')
    endfunction
endif

"" Return character at given position with multibyte handling
" @arg [Number, Number] as coordinate or expression for position :h line()
" @return String
function! s:get_pos_char(...) abort
    let pos = get(a:, 1, '.')
    let [line, col] = type(pos) is# type('') ? s:getcoord(pos) : pos
    return matchstr(getline(line), '.', col - 1)
endfunction

function! s:compare_pos(x, y) abort
    return max([-1, min([1,(a:x[0] == a:y[0]) ? a:x[1] - a:y[1] : a:x[0] - a:y[0]])])
endfunction


" @return Number: return multibyte aware column number in Visual mode to
" select
function! s:get_col_in_visual(pos) abort
    let [pos, other] = [a:pos, a:pos is# '.' ? 'v' : '.']
    let c = col(pos)
    let d = s:compare_pos(s:getcoord(pos), s:getcoord(other)) > 0
    \   ? len(s:get_pos_char([line(pos), c - (s:is_exclusive() ? 1 : 0)])) - 1
    \   : 0
    return c + d
endfunction

" Assume the current mode is middle of visual mode.
" @return selected text
function! GetSelectedText(...) abort
    let dedent = get(a:, 1, 0)
    let mode = get(a:, 2, mode(1))
    if mode == 'gv'
        normal! gv
        let mode = mode(1)
    endif
    let g:modetmp = mode
    let end_col = s:curswant() is s:INT.MAX ? s:INT.MAX : s:get_col_in_visual('.')
    let current_pos = [line('.'), end_col]
    let other_end_pos = [line('v'), s:get_col_in_visual('v')]
    let [begin, end] = s:sort_pos([current_pos, other_end_pos])
    if s:is_exclusive() && begin[1] !=# end[1]
        " Decrement column number for :set selection=exclusive
        let end[1] -= 1
    endif
    if mode !=# 'V' && begin ==# end
        let lines = [s:get_pos_char(begin)]
    elseif mode ==# "\<C-v>"
        let [min_c, max_c] = s:sort_num([begin[1], end[1]])
        let lines = map(range(begin[0], end[0]), '
        \   getline(v:val)[min_c - 1 : max_c - 1]
        \ ')
    elseif mode ==# 'V'
        let lines = getline(begin[0], end[0])
    else
        if begin[0] ==# end[0]
            let lines = [getline(begin[0])[begin[1]-1 : end[1]-1]]
        else
            let lines = [getline(begin[0])[begin[1]-1 :]]
            \         + (end[0] - begin[0] < 2 ? [] : getline(begin[0]+1, end[0]-1))
            \         + [getline(end[0])[: end[1]-1]]
        endif
    endif

    if dedent
        let l:idx = 0
        for line in lines
            if !exists('l:first_line_indent') || l:first_line_indent < 0
                let l:first_line_indent = match(line, '\S')
            endif
            if l:first_line_indent >= 0
                let lines[l:idx] = strpart(line, l:first_line_indent)
            endif
            let l:idx += 1
        endfor
    endif

    return join(lines, "\n") . (mode ==# 'V' ? "\n" : '')
endfunction
