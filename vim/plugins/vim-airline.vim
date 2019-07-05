set encoding=utf-8
set laststatus=2

function InitializeAirline()
    let g:airline_left_sep = ' '
    " let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ' '
    " let g:airline_right_alt_sep = ''
    let g:airline#extensions#tabline#left_sep = ' '
    " let g:airline#extensions#tabline#left_alt_sep = ' '
    let g:airline#extensions#tabline#right_sep = ' '
    " let g:airline#extensions#tabline#right_alt_sep = ' '
    let g:airline_symbols.notexists = ''

    let g:airline_powerline_fonts = 1
    let g:airline#extensions#tabline#enabled = 1
    let g:airline#extensions#tmuxline#enabled = 0

    "for colors in values(a:palette.normal)
    "  let colors[2] = 0
    "endfor
    let g:airline_mode_map = {
        \ '__' : '-',
        \ 'n'  : 'N',
        \ 'i'  : 'I',
        \ 'R'  : 'R',
        \ 'c'  : 'C',
        \ 'v'  : 'V',
        \ 'V'  : 'V',
        \ '' : 'V',
        \ 's'  : 'S',
        \ 'S'  : 'S',
        \ '' : 'S',
        \ 't'  : 'T',
        \ }

    let g:airline_section_z = airline#section#create(['%4l', '%{g:airline_symbols.linenr}', '%3v'])
endfunction

function! AirlineThemePatch(palette)
    if g:airline_theme == 'solarized'
        let a:palette.normal.airline_a = a:palette.insert.airline_a
        "let a:palette.normal.airline_a = [ '#ffffff', '#268bd2', 255, 33 ]
    endif
endfunction

let g:airline_theme_patch_func = 'AirlineThemePatch'
autocmd User AirlineAfterInit call InitializeAirline()
