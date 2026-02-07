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
