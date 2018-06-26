set laststatus=2
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

function! AirlineThemePatch(palette)
if g:airline_theme == 'solarized'
    let a:palette.normal.airline_a = a:palette.insert.airline_a
    "let a:palette.normal.airline_a = [ '#ffffff', '#268bd2', 255, 33 ]
endif
"for colors in values(a:palette.normal)
"  let colors[2] = 0
"endfor
endfunction
let g:airline_theme_patch_func = 'AirlineThemePatch'
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
    \ }

let g:airline_section_z = airline#section#create(['%4l', '%{g:airline_symbols.linenr}', '%3v'])