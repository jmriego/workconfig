filetype plugin on

" Loaded plugins {{{
if has('packages')
    packadd minpac

    let g:plugs_order = []
    function! s:track_plugin(plugin_source, ...)
        let options = get(a:, 1, {})
        call minpac#add(a:plugin_source, options)
        for plugin_name in keys(g:minpac#pluglist)
            " add the plugin name just added to minpac to g:plugs_order
            " it will be the only one in g:minpac#pluglist we dont have yet
            if index(g:plugs_order, plugin_name) == -1
                call add(g:plugs_order, plugin_name)
                break
            endif
        endfor
    endfunction

    call minpac#init({'progress_open': 'vertical'})
    command! -nargs=+ Plug call s:track_plugin(<args>)
    command! -nargs=0 PlugUpdate call minpac#update()
else
    call plug#begin()
endif

if executable('nodejs') || executable('node')
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
Plug 'altercation/vim-colors-solarized'
Plug 'junegunn/vim-easy-align'
if has('python') || has ('python3')
    Plug 'jmriego/vim-ipython'
    Plug 'jmcantrell/vim-virtualenv'
endif
Plug 'junegunn/fzf', {'do': ':silent! !./install --all' }
Plug 'junegunn/fzf.vim'
Plug 'kana/vim-textobj-user'
Plug 'kana/vim-textobj-indent'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
" Plug 'edkolev/tmuxline.vim' " only while modifying the tmux status line
Plug 'preservim/vimux'
Plug 'tpope/vim-dispatch'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-projectionist'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-abolish'
Plug 'tomtom/tcomment_vim'
Plug 'ryanoasis/vim-devicons'
Plug 'vimwiki/vimwiki'
Plug 'lepture/vim-jinja'

if !has('packages')
    call plug#end()
endif
" }}}

" Load plugin configuration files loop {{{
" for each plugin loaded above, load a file in vim/plugins with the name
" <plugin name>.vim where plugin name is all after the slash in lowercase
for plugin_name in g:plugs_order
    let plugin_cfg_file = expand('<sfile>:h') . '/vim/plugins/' . plugin_name . '.vim'
    if plugin_cfg_file =~ '\.vim\.vim$'
        let plugin_cfg_file = strpart(plugin_cfg_file, 0, strlen(plugin_cfg_file)-4)
    endif

    if filereadable(plugin_cfg_file)
        exec 'source ' . plugin_cfg_file
    endif
endfor
" }}}

exec 'set runtimepath+=' . expand('<sfile>:h') . '/vim/after'

" Appearance {{{
"hi CursorLine guibg=#303030
syntax on
set fdm=syntax
set modelines=1
set linespace=0
set ruler
set showcmd

if exists('$TMUX') " set transparent background for tmux
    hi! Normal ctermbg=NONE
    " hi! NonText ctermbg=NONE
endif

if has('terminal')
    autocmd BufCreate,BufWinEnter * if &buftype == 'terminal' | setlocal nocursorline | endif
    let g:terminal_ansi_colors = [
                \ '#073642',
                \ '#dc322f',
                \ '#859900',
                \ '#b58900',
                \ '#268bd2',
                \ '#d33682',
                \ '#2aa198',
                \ '#eee8d5',
                \ '#002b36',
                \ '#cb4b16',
                \ '#586e75',
                \ '#657b83',
                \ '#839496',
                \ '#6c71c4',
                \ '#93a1a1',
                \ '#fdf6e3']
endif
" }}}

" Platform specific configuration {{{
if has('mac') || has('unix')
    " Directory for swap files
    set directory=~/.vim/tmp,.
    set backupdir=~/.vim/tmp,.
    set undodir=~/.vim/tmp,.

    " map C-CR, S-CR and A-CR as F13, F14 and F15
    execute "set <F13>=\e[13;5u"
    execute "set <F14>=\e[13;1u"
    execute "set <F15>=\e[13;3u"
    execute "set <F16>=\e[8;5u"

    map  <F13> <C-CR>
    map! <F13> <C-CR>
    map  <F14> <S-CR>
    map! <F14> <S-CR>
    map  <F15> <A-CR>
    map! <F15> <A-CR>
    map  <F16> <C-BS>
    map! <F16> <C-BS>
elseif has('win32')  || has('win64')
    " Set directories
    " Directory for finding files and Python
    "set path=C:/Users/riegjos/Documents/SVN/**
    " Get the location of Anaconda and its packages
    if executable('conda')
        let conda_info = json_decode(system('conda info --json'))
        let conda_root = conda_info['root_prefix']
        let conda_packages_root = conda_root . '\Lib\site-packages'
        let $PATH .= '; ' . conda_root
        let $PATH .= '; ' . conda_packages_root
    endif
    " Directory for swap files
    set directory=%USERPROFILE%/vimfiles/tmp,.
    set backupdir=%USERPROFILE%/vimfiles/tmp,.
    set undodir=%USERPROFILE%/vimfiles/tmp,.
    set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:
endif

if has('win32unix')
    " map C-CR, S-CR and A-CR as F13, F14 and F15 in mintty
    execute "set <F13>=\e[25~"
    execute "set <F14>=\e[26~"
    execute "set <F15>=\e[27~"
    execute "set <F16>=\e[28~"
endif

" Making vim work properly in a terminal
if has('mouse')
  set mouse=a
  if &term =~ "xterm" || &term =~ "screen"
    " as of March 2013, this works:
    set ttymouse=xterm2

    " previously, I found that ttymouse was getting reset, so had
    " to reapply it via an autocmd like this:
    autocmd VimEnter,FocusGained,BufEnter * set ttymouse=xterm2
  endif
endif

" }}}

" General options {{{
" Set basic options
let mapleader=" "
let maplocalleader=" "
set noautoread
set sessionoptions=blank,buffers,tabpages,winsize
autocmd VimEnter * filetype plugin on
set hlsearch
set incsearch
set wrap
set nowrapscan
set backspace=indent
set tagcase=match
set diffopt=filler,vertical
set history=5000

" Set whitespace options
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Show the wild mode menu
set wildmenu
set wildmode=full
highlight WildMenu cterm=underline

" Language and Unicode
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif
  set encoding=utf-8
  setglobal fileencoding=utf-8
  "setglobal bomb
  set fileencodings=ucs-bom,utf-8,latin1
endif

" Avoid the press enter prompt when saving remote files
let g:netrw_silent=1
let g:netrw_banner=0
" }}}

" Custom Functions {{{
exec 'source ' . expand('<sfile>:h') . '/' . 'vim/source_line.vim'
exec 'source ' . expand('<sfile>:h') . '/' . 'vim/get_selected_text.vim'
exec 'source ' . expand('<sfile>:h') . '/' . 'vim/slime.vim'
exec 'source ' . expand('<sfile>:h') . '/' . 'vim/command_line_processing.vim'

" Add command for counting word frequency
function! WordFrequency() range
  let all = split(join(getline(a:firstline, a:lastline)), '\A\+')
  let frequencies = {}
  for word in all
    let frequencies[word] = get(frequencies, word, 0) + 1
  endfor
  new
  setlocal buftype=nofile bufhidden=hide noswapfile tabstop=20
  for [key,value] in items(frequencies)
    call append('$', value."\t".key)
  endfor
  sort i
endfunction
command! -range=% WordFrequency <line1>,<line2>call WordFrequency()

" Add DiffSaved command to compare buffer with Saved version
function! s:DiffWithSaved()
    let filetype=&ft
    diffthis
    vnew | r # | normal! 1Gdd
    diffthis
    exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype
endfunction
com! DiffSaved call s:DiffWithSaved()

function! GetScriptNumber(script_name)
    redir => s:scriptnames
    silent! scriptnames
    redir END

    for script in split(s:scriptnames, "\n")
        if script =~ a:script_name
            return str2nr(split(script, ":")[0])
        endif
    endfor
endfunction

function! DeleteHiddenBuffers(force) " Vim with the 'hidden' option
    let tpbl=[]
    call map(range(1, tabpagenr('$')), 'extend(tpbl, tabpagebuflist(v:val))')
    for buf in filter(range(1, bufnr('$')), 'bufexists(v:val) && index(tpbl, v:val)==-1')
        silent execute 'bwipeout' . (a:force ? '! ' : ' ') . buf
    endfor
    endfunction
command! -bang DeleteHiddenBuffers call DeleteHiddenBuffers(<bang>0)

" }}}

" File search settings {{{
" The Silver Searcher
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

" Ignore these files. It also affects ctrlp
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.pyc
" }}}

" Python configuration and plugins {{{
"Python files
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent

" Windows options
    " Navigate to other windows with Ctrl+HJKL
    nnoremap <C-J> <C-W><C-J>
    nnoremap <C-K> <C-W><C-K>
    nnoremap <C-L> <C-W><C-L>
    nnoremap <C-H> <C-W><C-H>

    " Preview windows and help windows open in a vertical split
    autocmd BufNew * if &previewwindow | wincmd L | endif
    autocmd FileType help wincmd L

    " Minimized Windows only take one line for the filename/status line
    " set wmh=0

" Visual mode options
    " Selected text in blue
    "hi Visual guibg=#5555FF

    " In visual mode, you can search for selected text with * and #
    function! s:VSetSearch()
      let temp = @@
      norm! gvy
      let @/ = '\V' . substitute(escape(@@, '\'), '\n', '\\n', 'g')
      let @@ = temp
    endfunction

    vnoremap * :<C-u>call <SID>VSetSearch()<CR>//<CR>
    vnoremap # :<C-u>call <SID>VSetSearch()<CR>??<CR>
" }}}

" GUI options {{{
if has('gui_running')
    " Change GUI to fullscreen and back with F11
    function! ToggleGUICruft()
      if &guioptions=='i'
        exec('set guioptions=iTrLm')
      else
        exec('set guioptions=i')
      endif
    endfunction
    map <F11> <Esc>:call ToggleGUICruft()<cr>
    set guioptions=i " by default, hide gui menus

    set noballooneval
    set guifont=UbuntuMono\ NF:h11,Ubuntu\ Mono\ derivative\ Powerline:h11
endif
" }}}

" Key mappings {{{
nnoremap <Leader>/ :noh<CR>
nnoremap <Leader>? :%s///gn<CR>
nnoremap <Leader>h :%! xxd<CR>
nnoremap <Leader>H :%! xxd -r<CR>
nnoremap <Leader>] <C-w><C-]><C-w>L
nnoremap <Leader>r :redraw!<CR>

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
autocmd FileType python nnoremap <buffer> <Leader>pk :IPython<CR>
autocmd FileType sql nnoremap <buffer> <Leader>pk :IPythonDBTRPC --existing<CR>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nnoremap g<Space> :Git<Space>
" This is mainly to replace Git push/fetch with dispatch
cnoremap <CR> <C-\>eCommandLineProcessing()<CR><CR>

nnoremap <expr> <silent> [c &diff ? '[c' : ':call GotoPreviousCell()<CR>'
nnoremap <expr> <silent> ]c &diff ? ']c' : ':call GotoNextCell()<CR>'

nnoremap <expr> <silent> <C-p> ":" . ChooseCtrlPFunc() . "<CR>" 
nnoremap <Leader>gf :GFiles<CR>
nnoremap <Leader>f :Files<CR>
nnoremap <Leader><C-]> :Tags<CR>
nnoremap gb :Buffers<CR>
nnoremap <Leader>0 :History<CR>

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
if exists('*coc#status')
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"
endif

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-@> coc#refresh()

" Use `[c` and `]c` to navigate diagnostics
nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

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
imap <C-l> <Plug>(coc-snippets-expand)
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
