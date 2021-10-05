let g:coc_global_extensions = ['coc-pyright', 'coc-yaml', 'coc-snippets']
let g:coc_disable_startup_warning = 1

set completeopt=menuone,preview

" Fix for making <C-x> mode work properly
let g:just_entered_insert = 0

function! CompletionCallCX()
  if g:just_entered_insert > 0
    " for ignoring the next insert mode enter
    let g:just_entered_insert = -1
    return "\<C-o>\<Esc>\<C-x>"
  else
    return "\<C-x>"
  endif
endfunction

function s:enteredInsertCoc()
  if g:just_entered_insert < 0
    let g:just_entered_insert = 0
  else
    let g:just_entered_insert = 1
  endif
endfunction

inoremap <expr> <silent> <C-x> CompletionCallCX()

set hidden

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

" You will have bad experience for diagnostic messages when it's default 4000.
set updatetime=300

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup cocgroup
  autocmd!
  autocmd InsertEnter * call s:enteredInsertCoc()
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add status line support, for integration with other plugin, checkout `:h coc-status`
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
