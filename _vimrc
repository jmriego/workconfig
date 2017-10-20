call plug#begin()
Plug 'altercation/vim-colors-solarized'
Plug 'junegunn/vim-easy-align'
if has('python') || has ('python3')
    Plug 'SirVer/ultisnips'
    Plug 'davidhalter/jedi-vim'
    Plug 'wilywampa/vim-ipython'
endif
Plug 'jmcantrell/vim-virtualenv'
Plug 'tmhedberg/SimpylFold'
Plug 'Konfekt/FastFold'
Plug 'nvie/vim-flake8'
Plug 'tell-k/vim-autopep8'
Plug 'kien/ctrlp.vim'
Plug 'kana/vim-textobj-user'
if has('lua')
    Plug 'Shougo/neocomplete.vim'
endif
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

" The Silver Searcher
if executable('ag')
  " Use ag over grep
  " set grepprg=ag\ --nogroup\ --nocolor
endif

" Ignore these files. It also affects ctrlp
set wildignore+=*\\tmp\\*,*.swp,*.zip,*.exe,*.pyc

" Appearence
"hi CursorLine guibg=#303030
syntax on
set cursorline
set fdm=syntax
set linespace=0
set ruler
set showcmd

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

" Set whitespace options
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent


" Completion options
set completeopt=longest,menuone
set omnifunc=syntaxcomplete#Complete

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

" Plugin solarized
if &runtimepath =~ 'solarized'
    try
        set background=light
        let g:solarized_visibility = "high"
        let g:solarized_contrast = "high"
        let g:solarized_termcolors=16
        colorscheme solarized
    catch
    endtry
endif

" Plugin vim-easy-align
" Start interactive EasyAlign in visual mode (e.g. vipga) and for a motion/text object (e.g. gaip)
if &runtimepath =~ 'vim-easy-align'
    xmap ga <Plug>(EasyAlign)
    nmap ga <Plug>(EasyAlign)
endif

" Plugin vim-ipython
" <Leader>k to connect to IPython
" <C-CR> to run current cell
" <S-CR> to run current cell and move cursor to the next one
if &runtimepath =~ 'vim-ipython'
    let g:ipy_perform_mappings = 0
    let g:ipy_completefunc = 'global'
    let g:ipy_monitor_subchannel = 1

    nmap <Leader><CR> <Plug>(IPython-UpdateShell)
    nmap <Leader>i :silent IPythonInput<CR>:sleep 500m<CR><Plug>(IPython-UpdateShell)

    nmap <C-CR> m`Vic<Plug>(IPython-RunLines)``:sleep 500m<CR><Plug>(IPython-UpdateShell)
    vmap <C-CR> <Plug>(IPython-RunLines):sleep 500m<CR><Plug>(IPython-UpdateShell)
    nmap <S-CR> Vic<Plug>(IPython-RunLines)jjvico<Esc>:sleep 500m<CR><Plug>(IPython-UpdateShell)
    vmap <S-CR> <Plug>(IPython-RunLines)jj:sleep 500m<CR><Plug>(IPython-UpdateShell)
    nmap <A-CR> <Plug>(IPython-RunLine):sleep 500m<CR><Plug>(IPython-UpdateShell)

    noremap <Leader>k :IPython<CR>
    nmap <Leader>d <Plug>(IPython-OpenPyDoc)
endif

" Plugin jedi-vim
if &runtimepath =~ 'jedi-vim'
    let g:jedi#auto_vim_configuration = 0
    "let g:jedi#force_py_version = "3"
    let g:jedi#popup_select_first = 0
    let g:jedi#completions_enabled = 1
    let g:jedi#smart_auto_mappings = 0
    let g:jedi#auto_close_doc = 0
    let g:jedi#documentation_command = "<leader>D"
    let g:jedi#usages_command = "<leader>u"
    let g:jedi#goto_assignments_command = ""
    let g:jedi#goto_command = "<leader>g"
    let g:jedi#popup_on_dot = 0
    let g:jedi#show_call_signatures = 0
endif

" Plugin vim-flake
if &runtimepath =~ 'vim-flake8'
    let g:flake8_cmd="flake8"
endif

" Plugin neocomplete
if &runtimepath =~ 'neocomplete'
    let g:neocomplete#enable_at_startup = 1
    let g:neocomplete#min_keyword_length = 1
    let g:neocomplete#fallback_mappings = ["\<C-x>\<C-o>"]
endif

" Plugin ctrlp.vim
if &runtimepath =~ 'ctrlp.vim'
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
    let g:ctrlp_map = '<Leader><C-p>'
    nnoremap <Leader><C-]> :CtrlPTag<CR>
    nnoremap <C-\> :CtrlPBuffer<CR>
    nnoremap <C-p> :call CallCtrlP(getcwd())<CR>

    if executable('ag')
        " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
        let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
        " ag is fast enough that CtrlP doesn't need to cache
        let g:ctrlp_use_caching = 0
    endif
endif

" Plugin UltiSnips
if &runtimepath =~ 'ultisnips'
    if has('win32')  || has('win64')
        let g:UltiSnipsSnippetDir=$HOME.'/vimfiles/UltiSnips'
    else
        let g:UltiSnipsSnippetDir=$HOME.'/.vim/UltiSnips'
    endif
    let g:UltiSnipsExpandTrigger="<tab>"
    let g:UltiSnipsJumpForwardTrigger="<tab>"
    let g:UltiSnipsJumpBackwardTrigger="<S-tab>"
endif


" Plugin vim-textobj-user
" Create cell text objects which are regions of text delimited by
" lines starting with ##
if &runtimepath =~ 'vim-textobj-user'
    exec 'source ' . expand('<sfile>:h') . '/python_cell_userobj.vim'
    nnoremap <expr> [c &diff ? '[c' : ':call GotoPreviousCell()<CR>'
    nnoremap <expr> ]c &diff ? ']c' : ':call GotoNextCell()<CR>'
endif

" Plugin vim-airline
if &runtimepath =~ 'vim-airline'
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
endif

if &runtimepath =~ 'vim-fugitive'
    nnoremap <Leader>gd :Gdiff<CR>
    nnoremap <Leader>gs :Gstatus<CR>
    nnoremap <Leader>gb :Gblame<CR>
    nnoremap <Leader>gl :Glog<CR>
endif

" Plugin benmills/vimux
if &runtimepath =~ 'vimux'
    map <Leader>vp :VimuxPromptCommand<CR>
    map <Leader>vl :VimuxRunLastCommand<CR>
    map <Leader>vi :VimuxInspectRunner<CR>
    map <Leader>vz :VimuxZoomRunner<CR>

    function! VimuxSlime()
        call VimuxSendText(@v)
        if @v !~ '\n$'
            call VimuxSendKeys("Enter")
        endif
    endfunction
    " If text is selected, save it in the v buffer and send that buffer it to tmux
    vmap <Leader>vs "vy :call VimuxSlime()<CR>
    " Select current paragraph and send it to tmux
    nmap <Leader>vs vip<Leader>vs<CR>
endif

" Plugin ludovicchabant/vim-gutentags
if &runtimepath =~ 'vim-gutentags'
    let g:gutentags_cache_dir = "~/temp"
endif

" Plugin tomtom/tcomment_vim
if &runtimepath =~ 'tcomment_vim'
    let g:tcommentTextObjectInlineComment = 'iC'
endif

"Python files
au BufNewFile,BufRead *.py
    \ set tabstop=4 |
    \ set softtabstop=4 |
    \ set shiftwidth=4 |
    \ set expandtab |
    \ set autoindent

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

" Several mappings
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

" GUI options
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
    set guifont=Ubuntu\ Mono\ derivative\ Powerline:h11
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


" Other functionality

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

if exists('$TMUX') " set transparent background for tmux
    hi! Normal ctermbg=NONE
    " hi! NonText ctermbg=NONE
endif
