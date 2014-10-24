set nocompatible              " be iMproved
" Spacebar is a much better leader than \ or ,
let mapleader = "\<Space>"

" Automatically source the vimrc file after saving it
if has("autocmd")
  autocmd bufwritepost .vimrc source $MYVIMRC
endif

""""" PLUGINS """""
call plug#begin()

Plug 'alfredodeza/pytest.vim'
nmap <silent><Leader>F :Pytest file verbose<CR>
nmap <silent><Leader>c :Pytest class verbose<CR>
nmap <silent><Leader>m :Pytest method verbose<CR>
nmap <silent><Leader>tf :Pytest function verbose<CR>

Plug 'bling/vim-airline'
let g:airline#extensions#hunks#enabled = 0
Plug 'christoomey/vim-tmux-navigator'

Plug 'ervandew/supertab'
Plug 'SirVer/ultisnips'
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
Plug 'honza/vim-snippets'

Plug 'rking/ag.vim'
Plug 'kien/ctrlp.vim'
" Go to symbol
map <leader>s :CtrlPBufTag<CR>
" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
" Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files.
  let g:ctrlp_user_command = 'ag %s -i -l --nocolor --nogroup --ignore ''.git'' --ignore ''.DS_Store'' --ignore ''.ropeproject'' --ignore ''node_modules'' --hidden -g ""'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
  nnoremap <leader>f :Ag<space>
else
  noremap <leader>f :Ack<space>
endif

Plug 'majutsushi/tagbar'
" Open tagbar
map <leader>\ :Tagbar<CR>
let g:tagbar_autofocus = 1
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'mattn/emmet-vim'
imap <C-a> <C-y>,
Plug 'ntpeters/vim-better-whitespace'
" Strip whitespace with space-space-w
nmap <leader><leader>w :StripWhitespace<CR>
Plug 'Raimondi/delimitMate'  " autoclose parens, quotes, etc.

Plug 'scrooloose/nerdtree'
nnoremap <leader>d :NERDTreeToggle<CR>
" Single clicks open directories and files
let g:NERDTreeMouseMode = 3
let g:NERDTreeRespectWildIgnore = 1
Plug 'scrooloose/syntastic'
let g:syntastic_mode_map = { 'mode': 'active',
 \ 'active_filetypes': [],
 \ 'passive_filetypes': [ 'html', 'rst', 'md'] }
let g:syntastic_python_checkers = ['flake8', 'python']
let g:syntastic_javascript_checkers = ['jshint']
" Disable some features to make syntastic faster
let g:syntastic_enable_signs = 0
let g:syntastic_enable_balloons = 0
Plug 'tomtom/tlib_vim'
Plug 'tpope/vim-rsi'  " unix keybindings in insert mode
Plug 'tpope/vim-commentary'
" Toggle comment with space-/
nmap <leader>/ gcc
vmap <leader>/ gc
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'mattn/webapi-vim' " needed by gist-vim
" Github/Gist
Plug 'mattn/gist-vim'
" Make gists private by default
let g:gist_post_private = 1
Plug 'airblade/vim-gitgutter'
" Disable gitgutter's bindings to avoid clashes
let g:gitgutter_map_keys = 0
nmap <leader>gh <Plug>GitGutterStageHunk
nmap <leader>gH <Plug>GitGutterRevertHunk
nmap [h <Plug>GitGutterPrevHunk
nmap ]h <Plug>GitGutterNextHunk
Plug 'tpope/vim-fugitive'
map <leader>gs :Gstatus<CR>
" <leader>gs mapping has a lag, so I use this one instead
map <leader>S :Gstatus<CR>
map <leader>gb :Gblame<CR>
" Open current file on Github
map <leader>gB :Gbrowse -<CR>
" Open currently selected lines on Github
vmap <leader>gB :Gbrowse -<CR>
map <leader>gr :Gread<CR>
map <leader>gw :Gwrite<CR>
noremap <Leader>gsh :Git push<CR>

" Colors
Plug 'flazz/vim-colorschemes'

" Syntax and languages
Plug 'mitsuhiko/vim-jinja'
Plug 'stephpy/vim-yaml'
Plug 'chase/vim-ansible-yaml'
Plug 'klen/python-mode'
Plug 'elzr/vim-json'
" Turn off stuff I don't use
let g:pymode_doc = 0
let g:pymode_run = 0
let g:pymode_folding = 0
let g:pymode_virtualenv = 0
let g:pymode_breakpoint = 0
" don't use linter, we use syntastic for that
let g:pymode_lint = 0
let g:pymode_lint_on_write = 0
let g:pymode_indent = 0
" Don't look for .ropeproject directories in parent directories
let g:pymode_rope_lookup_project = 0
set completeopt=menu " prevent pymode from showing documentation on autocomplete
                    " https://github.com/klen/python-mode/issues/384
" When using goto_definition, open in the current window instead of creating a
" new window
let g:pymode_rope_goto_definition_cmd = 'e'
Plug 'pangloss/vim-javascript'
if executable('npm')
  " Use tern for goto_definition and refactoring
  Plug 'marijnh/tern_for_vim', {'do': 'npm install'}
  " Go to definition with <C-c>g (just like in python-mode)
  autocmd Filetype javascript noremap <buffer> <C-c>g :TernDef<CR>
  " Rename with <C-c>rr (also like in python-mode)
  autocmd Filetype javascript noremap <buffer> <C-c>rr :TernRename<CR>
endif
Plug 'sophacles/vim-bundle-mako'
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled=1

Plug 'ZoomWin'
Plug 'terryma/vim-multiple-cursors'
" For previewing markdown, rst ,etc
Plug 'greyblake/vim-preview'
Plug 'matchit.zip'
Plug 'duff/vim-scratch'
" Open scratch buffer with space-tab
command! ScratchToggle call ScratchToggle()

function! ScratchToggle()
    if exists("w:is_scratch_window")
        unlet w:is_scratch_window
        exec "q"
    else
        exec "normal! :Sscratch\<cr>\<C-W>L"
        let w:is_scratch_window = 1
    endif
endfunction

nnoremap <silent> <leader><tab> :ScratchToggle<cr>

" Load plugins
call plug#end()            " required
filetype plugin indent on    " required

""" end plugins """

""" BASE CUSTOMIZATIONS """
set encoding=utf-8
syntax enable
set autoindent
set autoread " reload files when changed on disk, i.e. via `git checkout`
set backupcopy=yes
set clipboard=unnamed " Make "yanks" work with system clipboard
set ignorecase " case-insensitive search
set incsearch " search as you type
set wildmenu " show a navigable menu for tab completion
set wildmode=longest,list,full

" Indents
set expandtab " expand tabs by default (overloadable per file type later)
set tabstop=4 " a tab is 4 spaces
set softtabstop=4 " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=4 " number of spaces to use for autoindenting
set shiftround " use multiple of shiftwidth when indenting with '<' and '>'

set nobackup
set noswapfile  " Prevent annoying swapfile dialogs
" No bells
set noerrorbells
set visualbell
set t_vb=
""" VISUAL SETTINGS """

set t_Co=256 " Must be 256 for many themes to display correctly
" May want to have different schemes for termvim vs gvim
if has('gui_running')
    silent! colorscheme hybrid
else
    silent! colorscheme hybrid
endif

" Show trailing whitespace
set list
set listchars=tab:▸\ ,trail:▫

" This check is needed because breakindent isn't yet available on Macvim =(
if v:version > 704 || v:version == 704 && has("patch338")
  set breakindent " indent on linebreak
  set showbreak=..
endif

if &term =~ '256color'
  set t_ut=
endif

set cursorline  " have a line indicate cursor location
set foldmethod=manual
set previewheight=25  " Larger preview height
set number " Show line numbers on the sidebar.
" Do not fold by default.
set nofoldenable

" Set minimum window size to 79x5.
set winwidth=79
set winheight=5
set winminheight=5

" Patterns for expand(), ctrlp, etc. to ignore
set wildignore+=log/**,node_modules/**,target/**,tmp/**,*.rbc/,.git/*,*/.hg/*,*/.svn/*
" Disable output, vcs, archive, rails, temp and backup files.
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*.swp,*~,._*
set wildignore+=*.pyc
" Enable basic mouse behavior such as resizing buffers.
set mouse=a
set mousemodel=popup " Right-click pops up a menu
if exists('$TMUX') " Support resizing in tmux
  set ttymouse=xterm2
endif

" Persistent undo
if exists("+undofile")
" undofile - This allows you to use undos after exiting and restarting
" This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo//
  set undodir+=~/.vim/undo//
  set undofile
endif

" Make sure Vim returns to the same line when you reopen a file.
" Thanks, Amit
augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" Stop that stupid window from popping up
map q: :q

" Change cursor style when entering INSERT mode (works in tmux!)
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" Always focus on splited window.
nnoremap <C-w>s <C-w>s<C-w>w
nnoremap <C-w>v <C-w>v<C-w>w

""" Search
set hlsearch " Highlight search results
set ignorecase " Ignore case when searching.
set smartcase " Don't ignore case when search has capital letter

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

""" SHORTCUTS """
inoremap jk <Esc>
inoremap kj <Esc>

set pastetoggle=<leader>z  " toggle paste mode

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" select last pasted text
nnoremap gp `[v`]

" Open help in a new tab
cabbrev h tab h

" Easy syntax switching
nnoremap <leader>Tp :set ft=python<CR>
nnoremap <leader>Tj :set ft=javascript<CR>
nnoremap <leader>Tr :set ft=rst<CR>

" Quickly edit vimrc
nmap <leader>, :tabedit $MYVIMRC<CR>

" Quickly write/quit/save-and-quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>Q :wq<CR>

" Quickly open netrw
nnoremap <leader>e :e.<CR>

" Unhighlight search
nnoremap <Leader>n :nohlsearch<CR><C-L>

" Quick split
nnoremap <Leader>v <C-w>v<C-w>w

" Quick copy whole file
map <leader>a :%y+<CR>

" Make D delete to end of line
nnoremap D d$

" Make Y yank to end of line
nnoremap Y y$

" Go to beginning/end of line
noremap <leader>h ^
noremap <leader>l $


" Split line (sister to [J]oin lines)
nnoremap S i<cr><esc>^mwgk:silent! s/\v +$//<cr>:noh<cr>`w

" Move vertically over wrapped lines
nmap j gj
nmap k gk

"" Tabs
nnoremap <silent> <S-t> :tabnew<CR>

""" Syntax
" fdoc is yaml
autocmd BufRead,BufNewFile *.fdoc set filetype=yaml

" rst
autocmd BufNewFile,BufRead *.txt setlocal ft=rst
autocmd FileType rst setlocal nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
\ formatoptions+=nqtl

" markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd FileType markdown setlocal nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
\ formatoptions+=nqtl

" yaml
autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2

" vim
autocmd FileType vim setlocal shiftwidth=2 tabstop=2 softtabstop=2

" commit messages
autocmd Filetype gitcommit setlocal nolist textwidth=72

" GUI settings, e.g. MacVim
set guifont=Sauce\ Code\ Powerline:h12
if has('gui_running')
    if has('mac')
        set transparency=0
        " Hide scrollbars in MacVim
        set guioptions-=T
        set guioptions-=r
        set go-=L
    endif
endif
