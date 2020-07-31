set nocompatible              " be iMproved
" Spacebar is a much better leader than \ or ,
let mapleader = "\<Space>"

set modifiable
" Automatically source the vimrc file after saving it
autocmd bufwritepost .vimrc source $MYVIMRC

""""" PLUGINS """""
call plug#begin()

" Nice note taking plugin
Plug 'xolox/vim-misc'
Plug 'xolox/vim-notes'
:let g:notes_directories = ['~/Documents/Notes']
:let g:notes_suffix = '.txt'


" Window swap
Plug 'wesQ3/vim-windowswap'

"Puppet
Plug 'rodjek/vim-puppet'

" ESSENTIALS
Plug 'fabianvf/pytest.vim'
nmap <silent><Leader>tF :Pytest file verbose<CR>
nmap <silent><Leader>tc :Pytest class verbose<CR>
nmap <silent><Leader>tm :Pytest method verbose<CR>
nmap <silent><Leader>tf :Pytest function verbose<CR>
nmap <silent><Leader>tdF :Pytest file verbose doctest<CR>
nmap <silent><Leader>tdc :Pytest class verbose doctest<CR>
nmap <silent><Leader>tdm :Pytest method verbose doctest<CR>
nmap <silent><Leader>tdf :Pytest function verbose doctest<CR>

Plug 'bling/vim-airline'
let g:airline#extensions#hunks#enabled = 0
Plug 'christoomey/vim-tmux-navigator'

Plug 'tpope/vim-sensible'
Plug 'rstacruz/vim-opinion'
Plug 'ervandew/supertab'
Plug 'ctrlpvim/ctrlp.vim'
" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  Plug 'rking/ag.vim'
" Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files.
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  nnoremap <leader>f :Ag<space>
else
  Plug 'mileszs/ack.vim'
  noremap <leader>f :Ack<space>
endif
Plug 'tacahiroy/ctrlp-funky'
" Go to symbol
map <leader>r :CtrlPFunky<CR>
let g:ctrlp_funky_syntax_highlight = 1
Plug 'tpope/vim-rsi'  " unix keybindings in insert mode
Plug 'tpope/vim-commentary'
" Toggle comment with space-/
nmap <leader>/ gcc
vmap <leader>/ gc
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'matchit.zip'
" Buffers
Plug 'moll/vim-bbye'
nnoremap X :Bdelete<CR>
Plug 'BufOnly.vim'

Plug 'scrooloose/nerdtree'
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>D :NERDTreeFind<CR>
" Single clicks open directories and files
let g:NERDTreeMouseMode = 3
let g:NERDTreeRespectWildIgnore = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']

Plug 'tpope/vim-obsession'

Plug 'scrooloose/syntastic'
nnoremap <leader>s :SyntasticCheck<CR>
" NOTE: Don't use syntastic with python; we use khuno for that
" let g:syntastic_mode_map = { 'mode': 'active',
"  \ 'active_filetypes': ['ruby'],
"  \ 'passive_filetypes': [ 'html', 'rst', 'md', 'python'] }
let g:syntastic_python_checkers = ['flake8', 'python']
let g:syntastic_ruby_checkers = ['rubylint', 'mri']
" let g:syntastic_javascript_checkers = ['jsxhint', 'jshint']
" autocmd! BufEnter  *.jsx  let b:syntastic_checkers=['jsxhint']
" Disable some features to make syntastic faster
let g:syntastic_enable_signs = 0
let g:syntastic_enable_balloons = 0
" Non-blocking python checking
Plug 'alfredodeza/khuno.vim'

" NICE TO HAVE

" Plug 'bling/vim-airline'
" let g:airline_theme='tomorrow'
" Show buffers in tabline
" let g:airline#extensions#tabline#enabled = 1
" Disable stuff I don't need to see
" let g:airline#extensions#hunks#enabled = 0
" let g:airline#extensions#bufferline#enabled = 1
" let g:airline#extensions#tagbar#enabled = 0
" let g:airline#extensions#virtualenv#enabled = 0
" let g:airline#extensions#csv#enabled = 0
Plug 'christoomey/vim-tmux-navigator'

Plug 'SirVer/ultisnips'
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
Plug 'honza/vim-snippets'
Plug 'stefandtw/quickfix-reflector.vim'
Plug 'rafaelfranca/rtf_pygmentize', {'on': 'RTFPygmentize'}
let g:rtfp_font = 'Ubuntu Mono'

Plug 'majutsushi/tagbar', {'on': 'Tagbar'}
" Open tagbar
map <leader>\ :Tagbar<CR>
let g:tagbar_autofocus = 1

Plug 'wellle/targets.vim'  " because cin), etc. is awesomeet g:tagbar_autofocus = 1
" Running Python tests
Plug 'tpope/vim-dispatch' " So we can run tests asynchronously
Plug 'janko-m/vim-test'  " For running tests
nmap <silent> <leader>tt :TestNearest<CR>
nmap <silent> <leader>tf :TestFile<CR>
nmap <silent> <leader>ts :TestSuite<CR>
nmap <silent> <leader>tl :TestLast<CR>
let test#strategy = "dispatch"
" Pass -s option to pytest so that we can use ipdb
let test#python#pytest#options = '-s'

Plug 'rust-lang/rust.vim'
Plug 'mattn/emmet-vim'  "Write HTML fast
Plug 'Raimondi/delimitMate'  " autoclose parens, quotes, etc.
Plug 'justinmk/vim-sneak'  " Quickly move around
Plug 'kristijanhusak/vim-multiple-cursors'
Plug 'greyblake/vim-preview'  "For previewing markdown, rst, etc.
Plug 'mtth/scratch.vim'
let g:scratch_height = 20
" Open scratch buffer with space-tab
nnoremap <silent> <leader><tab> :Scratch<cr>:set ft=python<cr>

" GIT
Plug 'airblade/vim-gitgutter'
" Set gitgutter's bindings manually to avoid clashes
let g:gitgutter_map_keys = 0
nmap <leader>gh <Plug>(GitGutterStageHunk)
nmap <leader>gH <Plug>(GitGutterRevertHunk)
nmap [h <Plug>(GitGutterPrevHunk)
nmap ]h <Plug>(GitGutterNextHunk)
Plug 'tpope/vim-fugitive'
map <leader>gs :Gstatus<CR>
map <leader>gb :Gblame<CR>
" Open current file on Github
map <leader>gB :Gbrowse -<CR>
" Open currently selected lines on Github
vmap <leader>gB :Gbrowse -<CR>
map <leader>gr :Gread<CR>
map <leader>gw :Gwrite<CR>
noremap <Leader>gp :Git push<CR>

" COLOR

Plug 'flazz/vim-colorschemes'

" SYNTAX/LANGUAGES

Plug 'hdima/python-syntax'
let g:python_highlight_all=1
Plug 'mitsuhiko/vim-jinja'
Plug 'stephpy/vim-yaml'
Plug 'chase/vim-ansible-yaml'
Plug 'elzr/vim-json'
Plug 'groenewege/vim-less'
Plug 'sophacles/vim-bundle-mako'
Plug 'mustache/vim-mustache-handlebars'
Plug 'tpope/vim-markdown'
let g:vim_markdown_folding_disabled=1
Plug 'mxw/vim-jsx'
Plug 'davidhalter/jedi-vim'
" Use buffers
let g:jedi#use_tabs_not_buffers = 0
" Just let me type!
let g:jedi#popup_select_first = 0
let g:jedi#popup_on_dot = 0
" Show call sigs slow things down for large projects
let g:jedi#show_call_signatures = 0
" Prefix all refactoring commands with <C-c> to avoid clashing
let g:jedi#goto_command = "<C-c>g"
let g:jedi#rename_command = "<C-c>r"
let g:jedi#usages_command = "<C-c>u"
let g:jedi#documentation_command = "<C-c>d"
Plug 'pangloss/vim-javascript'
if executable('npm')
  " Use tern for goto_definition and refactoring
  Plug 'marijnh/tern_for_vim', {'do': 'npm install'}
  " Go to definition with <C-c>g (just like in python-mode)
  autocmd Filetype javascript noremap <buffer> <C-c>g :TernDef<CR>
  " Rename with <C-c>rr (also like in python-mode)
  autocmd Filetype javascript noremap <buffer> <C-c>r :TernRename<CR>
endif
Plug 'sophacles/vim-bundle-mako'
Plug 'plasticboy/vim-markdown'
let g:vim_markdown_folding_disabled=1

" Idris stuff
Plug 'idris-hackers/idris-vim'

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

""" Go configuration
Plug 'fatih/vim-go', { 'do': ':GoInstallBinaries' }
let g:go_fmt_command = "goimports"


call plug#end()
filetype plugin indent on

""" end plugins """

""" BASE CUSTOMIZATIONS """
set encoding=utf-8
set autoindent
set autoread " reload files when changed on disk, i.e. via `git checkout`
set backupcopy=yes
set clipboard=unnamedplus
set wildmenu wildmode=longest,list,full

" Indents
set expandtab " expand tabs by default (overloadable per file type later)
set tabstop=4 " a tab is 4 spaces
set softtabstop=4 " when hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=4 " number of spaces to use for autoindenting
set shiftround " use multiple of shiftwidth when indenting with '<' and '>'


" No bells
set noerrorbells visualbell t_vb=
""" VISUAL SETTINGS """

set t_Co=256 " Must be 256 for many themes to display correctly
" Favorites: hybrid iceberg Tomorrow hybrid-light
silent! colorscheme iceberg
command! TransparencyToggle call TransparencyToggle()

function! TransparencyToggle()
    if exists("w:is_transparent")
        unlet w:is_transparent
        exec "hi Normal ctermbg=" . w:normal_bg
        exec "hi NonText ctermbg=" . w:nontext_bg
        exec "hi CursorLine ctermbg=" . w:cursorline_bg
        exec "hi CursorLineNr ctermbg=" . w:cursornr_bg
        exec "hi LineNr ctermbg=" . w:linenr_bg
        exec "hi GitGutterAdd ctermbg=" . w:gitgutteradd_bg
        exec "hi GitGutterAdd ctermfg=" . w:gitgutteradd_fg
        exec "hi GitGutterChange ctermbg=" . w:gitgutterchange_bg
        exec "hi GitGutterChange ctermfg=" . w:gitgutterchange_fg
        exec "hi GitGutterDelete ctermbg=" . w:gitgutterdelete_bg
        exec "hi GitGutterDelete ctermfg=" . w:gitgutterdelete_fg

    else
        let w:normal_bg = synIDattr(synIDtrans(hlID('Normal')), 'bg')
        let w:nontext_bg = synIDattr(synIDtrans(hlID('NonText')), 'bg')
        let w:cursorline_bg = synIDattr(synIDtrans(hlID('CursorLine')), 'bg')
        let w:cursornr_bg = synIDattr(synIDtrans(hlID('CursorLineNr')), 'bg')
        let w:linenr_bg = synIDattr(synIDtrans(hlID('LineNr')), 'bg')
        let w:gitgutteradd_bg = synIDattr(synIDtrans(hlID('GitGutterAdd')), 'bg')
        let w:gitgutteradd_fg = synIDattr(synIDtrans(hlID('GitGutterAdd')), 'fg')
        let w:gitgutterchange_bg = synIDattr(synIDtrans(hlID('GitGutterChange')), 'bg')
        let w:gitgutterchange_fg = synIDattr(synIDtrans(hlID('GitGutterChange')), 'fg')
        let w:gitgutterdelete_bg = synIDattr(synIDtrans(hlID('GitGutterDelete')), 'bg')
        let w:gitgutterdelete_fg = synIDattr(synIDtrans(hlID('GitGutterDelete')), 'fg')

        exec "hi Normal ctermbg=none"
        exec "hi NonText ctermbg=none"
        exec "hi CursorLine ctermbg=none"
        exec "hi CursorLineNr ctermbg=none"
        exec "hi LineNr ctermbg=none"
        exec "hi GitGutterAdd ctermbg=none"
        exec "hi GitGutterAdd ctermfg=" . w:gitgutteradd_fg
        exec "hi GitGutterChange ctermbg=none"
        exec "hi GitGutterChange ctermfg=" . w:gitgutterchange_fg
        exec "hi GitGutterDelete ctermbg=none"
        exec "hi GitGutterDelete ctermfg=" . w:gitgutterdelete_fg
        let w:is_transparent = 1
    endif
endfunction

nnoremap <silent> <leader>t :TransparencyToggle<cr>
" May want to have different schemes for termvim vs gvim
" if has('gui_running')
"     silent! colorscheme emacs
" else
"     silent! colorscheme underwater
" endif

" Show trailing whitespace
set list listchars=tab:▸\ ,trail:▫

" Check is necessary because breakindent isn't yet available on MacVim =(
if exists('&breakindent') | set breakindent showbreak=.. | endif

if &term =~ '256color' | set t_ut= | endif

set cursorline  " have a line indicate cursor location
set previewheight=25  " Larger preview height

" Set minimum window size to 79x5.
set winwidth=79 winheight=5 winminheight=5

" Patterns for expand(), ctrlp, etc. to ignore
set wildignore+=log/**,node_modules/**,target/**,tmp/**,*.rbc/,.git/*,*/.hg/*,*/.svn/*
" Disable output, vcs, archive, rails, temp and backup files.
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*.swp,*~,._*
set wildignore+=*.pyc,*__pycache__*
" Enable basic mouse behavior such as resizing buffers.
set mouse=a mousemodel=popup " Right-click pops up a menu

if exists('$TMUX') && !has('nvim') " Support resizing in tmux
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
  set undodir=./.vim-undo// undodir+=~/.vim/undo// undofile
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

""" SHORTCUTS """
" Smash escape
inoremap jk <Esc>
" Switch between files
nnoremap <leader>b :e#<CR>
" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
" Move across buffers with arrow keys
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprev<CR>
" Remove trailing whitespace on <space><space>w
nnoremap <leader><leader>w :%s/\s\+$//<cr>:let @/=''<CR>
set pastetoggle=<leader>z  " toggle paste mode
" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %
" select last pasted text
nnoremap gp `[v`]
" Easy syntax switchin g
nnoremap <leader>Tp :set ft=python<CR>
nnoremap <leader>Tj :set ft=javascript<CR>
nnoremap <leader>Tr :set ft=rst<CR>
" Quickly edit vimrc
nmap <leader>, :e $MYVIMRC<CR>
" Quickly write/quit/save-and-quit
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
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
" Execute macro
nnoremap Q @q
" Move vertically over wrapped lines
nmap j gj
nmap k gk
"" Tabs
nnoremap <silent> tt :tabnew<CR>

""" Languages
augroup configgroup
  autocmd!
  " rst
  autocmd BufNewFile,BufRead *.txt setlocal ft=rst
  autocmd FileType rst setlocal wrap nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
  \ formatoptions+=nqtl
  " markdown
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  autocmd FileType markdown setlocal wrap nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
  \ formatoptions+=nqtl
  " yaml
  autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
  " vim
  autocmd FileType vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
  " javascript
  autocmd FileType javascript setlocal shiftwidth=4 tabstop=4 softtabstop=4
  " commit messages
  autocmd Filetype gitcommit setlocal nolist textwidth=72
augroup END

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

set relativenumber
set number
function! NumberToggle()
  if(&relativenumber == 1)
    set norelativenumber
    set number
    echo ':set number'
  else
    set relativenumber
    set number
    echo ':set relativenumber'
  endif
endfunc
nmap <silent><Leader>n :call NumberToggle()<CR>
