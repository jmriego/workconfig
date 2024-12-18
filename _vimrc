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

Plug 'altercation/vim-colors-solarized'
Plug 'junegunn/vim-easy-align'
if has('python') || has ('python3')
    Plug 'jupyter-vim/jupyter-vim'
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
  if has("mouse_sgr")
      set ttymouse=sgr
  elseif &term =~ "xterm" || &term =~ "screen"
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
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

augroup vimrc
    autocmd!
    autocmd VimEnter * exec 'source ' . expand('<sfile>:h') . '/vim/mappings.vim'
augroup END


" }}}

" vim:foldmethod=marker:foldlevel=0
