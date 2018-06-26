if has('win32')  || has('win64')
    let g:UltiSnipsSnippetDir=$HOME.'/vimfiles/UltiSnips'
else
    let g:UltiSnipsSnippetDir=$HOME.'/.vim/UltiSnips'
endif
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
