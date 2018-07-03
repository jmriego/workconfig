let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll)$',
  \ 'link': 'SOME_BAD_SYMBOLIC_LINKS',
\ }
let g:ctrlp_switch_buffer = 'eE'
let g:ctrlp_use_caching = 1
let g:ctrlp_working_path_mode = 'ra' " search project of current file
let g:ctrlp_by_filename = 1
" Let's use ag (or grep) instead of vim to search for files. Much faster
if executable('ag')
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
endif

" Remove the possible extensions shown in CtrlP
func! CallCtrlP(...)
    let g:ctrlp_ext_vars=[]
    if a:0 > 0
        CtrlP a:1
    else
        CtrlP
    endif
endfunc

let g:ctrlp_cmd = 'call CallCtrlP()'

if executable('ag')
    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
endif
