" Key mappings {{{
nnoremap <Leader>/ :noh<CR>
nnoremap <Leader>? :%s///gn<CR>
nnoremap <Leader>h :%! xxd<CR>
nnoremap <Leader>H :%! xxd -r<CR>
nnoremap <Leader>] <C-w><C-]><C-w>L
nnoremap <Leader>r :redraw!<CR>

nnoremap <C-W>S :Sex<CR>
nnoremap <C-W>V :Vex<CR>
nnoremap <C-W>E :Ex<CR>

map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vl :VimuxRunLastCommand<CR>
map <Leader>vc :VimuxInterruptRunner<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vI :VimuxInspectRunner<CR>:VimuxZoomRunner<CR>
map <Leader>vz :VimuxZoomRunner<CR>
map <Leader>vP :call VimuxReusePrevious()<CR>:VimuxPromptCommand<CR>

nmap <silent> <C-CR> :call VimSlime(&ft=="sql" ? "query-a" : "block", 0)<CR>
xmap <silent> <C-CR> :call VimSlime("", 0, 0)<CR>
nmap <silent> <S-CR> :call VimSlime(&ft=="sql" ? "query-i" : "block", 1)<CR>
xmap <silent> <S-CR> :call VimSlime("", 1, 0)<CR>
nmap <silent> <A-CR> :call VimSlime("line", "")<CR>
xmap <silent> <A-CR> :call VimSlime("", 0, 0)<CR>gv

nnoremap <expr> <leader>t ":wincmd b \| botright terminal ++close ++rows=".winheight(0)/4."\<CR>"

nnoremap <Leader>gd :Gvdiffsplit!<CR>
nnoremap <Leader>gs :execute "vertical Git \| wincmd L \| norm gU"<CR>
nnoremap <Leader>gb :Git blame<CR>
nnoremap <Leader>gl :0Gclog<CR>
nnoremap <Leader>ge :Gedit<CR>

noremap <Plug>(IPython-UpdateShell-Silent) :Python2or3 update_subchannel_msgs(force=True)<CR>
autocmd FileType python,sql nmap <buffer> <Leader><CR> <Plug>(IPython-UpdateShell-Silent)
autocmd FileType python nmap <buffer> <Leader>y :call SendText("import pyperclip; pyperclip.copy(_)", 1)<CR>
autocmd FileType sql nmap <buffer> <Leader>y :call SendText("%dbt_clipboard", 1)<CR>
autocmd FileType python nmap <buffer> <Leader>i :IPythonInput<CR><Plug>(IPython-UpdateShell-Silent)
autocmd FileType python,sql nmap <buffer> <Leader>: :call VimSlimePrompt("In []: ", 1)<CR>

nnoremap [<CR> :let g:vimux_dos_lines = !get(g:, "vimux_dos_lines", 0)<CR>
nnoremap ]<CR> :call VimuxSendKeys("Enter")<CR>

autocmd FileType scala nnoremap <buffer> [<CR> :call VimuxSlime(":paste")<CR>:let g:ignore_slime_affixes=1<CR>
autocmd FileType scala nnoremap <buffer> ]<CR> :call VimuxSlime("C-d", 0)<CR>:let g:ignore_slime_affixes=0<CR>
autocmd FileType scala let b:slime_preffix_suffix = [":paste" . "\n", "C-d"]

autocmd FileType sql let g:dbt_default_command = get(g:, "dbt_default_command", "%%compile_sql") | let b:slime_preffix_suffix = [g:dbt_default_command . "\n", ""]
autocmd FileType sql nnoremap <buffer> [<CR> :let g:dbt_default_command = "%%compile_sql" \| let b:slime_preffix_suffix = [g:dbt_default_command . "\n", ""]<CR>
autocmd FileType sql nnoremap <buffer> ]<CR> :let g:dbt_default_command = "%%run_sql" \| let b:slime_preffix_suffix = [g:dbt_default_command . "\n", ""]<CR>

noremap <Leader>d<CR> <C-w>P:%d<CR><C-w>p
autocmd FileType python nnoremap <buffer> <Leader>pk :JupyterConnect<CR>
autocmd FileType sql nnoremap <buffer> <Leader>pk :IPythonDBTRPC --existing<CR>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nnoremap g<Space> :Git<Space>
" This is mainly to replace Git push/fetch with dispatch
cnoremap <CR> <C-\>eCommandLineProcessing()<CR><CR>

nnoremap <expr> <silent> [c &diff ? '[c' : ':call GotoPreviousCell()<CR>'
nnoremap <expr> <silent> ]c &diff ? ']c' : ':call GotoNextCell()<CR>'

nnoremap <expr> <silent> <C-p> ":" . ChooseCtrlPFunc() . "<CR>" 
nnoremap <C-p><C-f> :Files<CR>
nnoremap <C-p><C-s> :GFiles?<CR>
nnoremap <C-p><C-b> :GDiffBranch master...<CR>
nnoremap <C-p><C-h> :History<CR>
nnoremap <Leader><C-]> :Tags<CR>
nnoremap gb :Buffers<CR>

nnoremap <expr> d<Space> ":Dispatch " . b:dispatch . " "
nnoremap c<CR> :Copen<CR>
nnoremap C<CR> :Copen!<CR>
nnoremap cu<CR> :call ChooseOpenURL()<CR>
nnoremap c<BS> :cclose<CR>
nnoremap <Leader>S :mksession!<CR>

" Use tab for trigger completion with characters ahead and navigate
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config
inoremap <silent><expr> <TAB>
      \ exists('*coc#status') ?
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh() : "\<Tab>"
inoremap <expr><S-TAB>
      \ exists('*coc#status') ?
      \ coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
      \ : "\<S-TAB>" 

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-@> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)
inoremap <silent> <F1> <C-r>=CocActionAsync('showSignatureHelp')<CR>

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
xmap <A-f>  <Plug>(coc-format-selected)
nmap <A-f>  <Plug>(coc-format-selected)

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use <C-l> for trigger snippet expand.
imap <C-l> <Plug>(coc-snippets-expand-jump)
" Use <C-j> for jump to next placeholder, it's default of coc.nvim
let g:coc_snippet_next = '<TAB>'
" Use <C-k> for jump to previous placeholder, it's default of coc.nvim
let g:coc_snippet_prev = '<S-TAB>'
" Use <C-j> for both expand and jump (make expand higher priority.)
imap <C-j> <Plug>(coc-snippets-expand-jump)

" Use <leader>x for convert visual selected code to snippet
xmap <leader>x  <Plug>(coc-convert-snippet)

" Use <tab> for select selections ranges, needs server support, like: coc-tsserver, coc-python
" nmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <TAB> <Plug>(coc-range-select)
" xmap <silent> <S-TAB> <Plug>(coc-range-select-backword)

" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

if has('terminal')
    tnoremap <C-w><C-w> <C-\><C-n>
    tnoremap <C-h> <C-w>h
    tnoremap <C-j> <C-w>j
    tnoremap <C-k> <C-w>k
    tnoremap <C-l> <C-w>l
    " F16 was mapped to <C-BS>
    tnoremap <F16> <C-w>.
endif
" }}}

" vim:foldmethod=marker:foldlevel=0
