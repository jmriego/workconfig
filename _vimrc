" Loaded plugins {{{
call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'junegunn/vim-easy-align'
if has('python') || has ('python3')
    Plug 'SirVer/ultisnips'
    Plug 'davidhalter/jedi-vim'
    Plug 'wilywampa/vim-ipython'
    Plug 'maralla/completor.vim'
    Plug 'jmcantrell/vim-virtualenv'
    Plug 'nvie/vim-flake8'
    Plug 'tell-k/vim-autopep8'
endif
Plug 'tmhedberg/SimpylFold'
Plug 'Konfekt/FastFold'
Plug 'kien/ctrlp.vim'
Plug 'kana/vim-textobj-user'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'christoomey/vim-tmux-navigator'
" Plug 'edkolev/tmuxline.vim' " only while modifying the tmux status line
Plug 'benmills/vimux'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
if executable('ctags')
    Plug 'ludovicchabant/vim-gutentags'
endif
Plug 'tomtom/tcomment_vim'
call plug#end()
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

" Appearance {{{
"hi CursorLine guibg=#303030
syntax on
set cursorline
set fdm=syntax
set modelines=1
set linespace=0
set ruler
set showcmd


if exists('$TMUX') " set transparent background for tmux
    hi! Normal ctermbg=NONE
    " hi! NonText ctermbg=NONE
endif
" }}}

" Platform specific configuration {{{
if has('mac')
    " Directory for swap files
    set directory=~/tmp,.
    set backupdir=~/tmp,.
    set undodir=~/tmp,.

    " map C-CR, S-CR and A-CR in iTerm as F13, F14 and F15
    "   it requires mapping them to the escape sequences O2P, O2Q and O2R
    if exists('$TMUX') " Tmux has different escape sequences
        execute "set <F13>=\e[1;2P"
        execute "set <F14>=\e[1;2Q"
        execute "set <F15>=\e[1;2R"
    else
        execute "set <F13>=\eO2P"
        execute "set <F14>=\eO2Q"
        execute "set <F15>=\eO2R"
    endif

    map  <F13> <C-CR>
    map! <F13> <C-CR>
    map  <F14> <S-CR>
    map! <F14> <S-CR>
    map  <F15> <A-CR>
    map! <F15> <A-CR>
elseif has('unix')
    " Directory for swap files
    set directory=~/tmp,.
    set backupdir=~/tmp,.
    set undodir=~/tmp,.
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
    set directory=%USERPROFILE%/tmp,.
    set backupdir=%USERPROFILE%/tmp,.
    set undodir=%USERPROFILE%/tmp,.
    set rop=type:directx,gamma:1.0,contrast:0.5,level:1,geom:1,renmode:4,taamode:
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

" Set whitespace options
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent

" Show the wild mode menu
set wildmenu
set wildmode=full

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
" }}}

" Custom Functions {{{
exec 'source ' . expand('<sfile>:h') . '/' . 'get_selected_text.vim'

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

" Toggle line numbers and relative line numbers
function! NumberToggle()
  if(&number == 1 || &relativenumber == 1)
    if(&number == 1 )
      set nonumber
    endif
    if(&relativenumber == 1 )
      set norelativenumber
    endif
  else
    set number
  endif
endfunc

function! RelNumberToggle()
  if(&relativenumber == 1)
    set number
    set norelativenumber
  else
    set number
    set relativenumber
  endif
endfunc

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
    autocmd WinEnter * if &previewwindow | wincmd L | endif
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
    set guifont=Ubuntu\ Mono\ derivative\ Powerline:h11,Ubuntu_Mono_derivative_Powerlin:h12
endif
" }}}

" Key mappings {{{
nnoremap <Leader>l :call NumberToggle()<CR>
nnoremap <Leader>L :call RelNumberToggle()<CR>
nnoremap <Leader>p :set list!<CR>
nnoremap <Leader>w :execute "set wrap! \| set wrap?"<CR>
nnoremap <Leader>W :execute "set wrapscan! \| set wrapscan?"<CR>
nnoremap <Leader>c :execute "set ignorecase! \| set ignorecase?"<CR>
nnoremap <Leader>/ :noh<CR>
nnoremap <Leader>? :%s///gn<CR>
nnoremap <Leader>h :%! xxd<CR>
nnoremap <Leader>H :%! xxd -r<CR>
nnoremap <Leader>] <C-w><C-]><C-w>L

map <Leader>vp :VimuxPromptCommand<CR>
map <Leader>vl :VimuxRunLastCommand<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vz :VimuxZoomRunner<CR>
map <Leader>vP :call VimuxReusePrevious()<CR>:VimuxPromptCommand<CR>

nmap <C-CR> :call VimuxSlime("Vip")<CR>
xmap <C-CR> :call VimuxSlime()<CR>
nmap <S-CR> :call VimuxSlime("Vip")<CR>})
xmap <S-CR> :call VimuxSlime()<CR>j
nmap <A-CR> :call VimuxSlime("V")<CR>
xmap <A-CR> :call VimuxSlime()<CR>gv

nnoremap <Leader>gd :Gdiff<CR>
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gl :Glog<CR>

noremap <Plug>(IPython-UpdateShell-Silent) :Python2or3 if update_subchannel_msgs(force=True) and not current_stdin_prompt: echo("vim-ipython shell updated",'Operator')<CR>
autocmd FileType python nmap <buffer> <Leader><CR> <Plug>(IPython-UpdateShell-Silent)
autocmd FileType python nmap <buffer> <Leader>i :IPythonInput<CR><Plug>(IPython-UpdateShell-Silent)

autocmd FileType python nnoremap <expr> <silent> <C-CR> IPythonConnected() ? ':callIPythonRunLines("Vic")<CR>' : ':call VimuxSlime("Vip")<CR>'
autocmd FileType python xnoremap <expr> <silent> <C-CR> IPythonConnected() ? ':callIPythonRunLines()<CR>' : ':call VimuxSlime()<CR>'
autocmd FileType python nnoremap <expr> <silent> <S-CR> IPythonConnected() ? ':callIPythonRunLines("Vic")<CR>]c' : ':call VimuxSlime("Vip")<CR>})'
autocmd FileType python xnoremap <expr> <silent> <S-CR> IPythonConnected() ? ':callIPythonRunLines()<CR>+' : ':call VimuxSlime()<CR>j'
autocmd FileType python nnoremap <expr> <silent> <A-CR> IPythonConnected() ? ':callIPythonRunLines("V")<CR>' : ':call VimuxSlime("V")<CR>'
autocmd FileType python xnoremap <expr> <silent> <A-CR> IPythonConnected() ? ':callIPythonRunLines()<CR>gv' : ':call VimuxSlime()<CR>gv'

noremap <Leader>d<CR> <C-w>P:%d<CR><C-w>p
noremap <Leader>k :IPython<CR>
autocmd FileType python nmap <Leader>d <Plug>(IPython-OpenPyDoc)

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

nnoremap <expr> <silent> [c &diff ? '[c' : ':call GotoPreviousCell()<CR>'
nnoremap <expr> <silent> ]c &diff ? ']c' : ':call GotoNextCell()<CR>'

let g:ctrlp_map = '<Leader><C-p>'
nnoremap <Leader><C-]> :CtrlPTag<CR>
nnoremap <C-\> :CtrlPBuffer<CR>
nnoremap <C-p> :call CallCtrlP(getcwd())<CR>
" }}}

" vim:foldmethod=marker:foldlevel=0
