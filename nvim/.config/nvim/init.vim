" Better leader key
let mapleader = "\<Space>"

""""""" PLUGINS """""""""""""
call plug#begin('~/.config/nvim/plugged')

Plug 'tpope/vim-sensible'
Plug 'rstacruz/vim-opinion'

" NerdTree
Plug 'scrooloose/nerdtree'
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>D :NERDTreeFind<CR>
let g:NERDTreeRepsectWildIgnore = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']

" Neomake / Linter
Plug 'neomake/neomake'
autocmd! BufWritePost * Neomake " Lint on save
let g:neomake_open_list = 0 " Dont open the errors list
let g:neomake_go_enabled_makers = [] " vim-go handles this
let g:neomake_python_enabled_makers = ['flake8']
let g:neomake_javascript_enabled_makers = ['jscs']

" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Python Autocomplete
Plug 'zchee/deoplete-jedi'
let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'


" Make Tmux panes not pains
Plug 'christoomey/vim-tmux-navigator'

" Fuzzy file searching
Plug 'ctrlpvim/ctrlp.vim'

if executable('ag')
  Plug 'rking/ag.vim'
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor
  " Use ag in CtrlP for listing files.
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  nnoremap <leader>f :Ag<space>
endif

" Toggle comment with space-/
Plug 'tpope/vim-commentary'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
let g:airline_theme='tomorrow'
" let g:airline_powerline_fonts = 1
" Show buffers in tabline
let g:airline#extensions#tabline#enabled = 1
" Disable stuff I don't need to see
let g:airline#extensions#hunks#enabled = 0
let g:airline#extensions#bufferline#enabled = 1
let g:airline#extensions#tagbar#enabled = 0
let g:airline#extensions#virtualenv#enabled = 0
let g:airline#extensions#csv#enabled = 0


Plug 'airblade/vim-gitgutter'
" Set gitgutter's bindings manually to avoid clashes
let g:gitgutter_map_keys = 0
nmap <leader>gh <Plug>GitGutterStageHunk
nmap <leader>gH <Plug>GitGutterRevertHunk
nmap [h <Plug>GitGutterPrevHunk
nmap ]h <Plug>GitGutterNextHunk

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

Plug 'flazz/vim-colorschemes'

" Add plugins to &runtimepath
call plug#end()
""""""" /PLUGINS """""""""""""



""""""" GENERAL """""""""""""
" Source this file on save
autocmd bufwritepost init.vim source ~/.config/nvim/init.vim

if has('vim_starting')
    set encoding=utf-8
endif

set autoindent
set autoread " reload files that have changed on disk, IE `git checkout`
set wildmenu wildmode=longest,list,full

set clipboard=unnamed " Make yanks work with system clipboard

" Indents
set expandtab " Expand tabs by default
set tabstop=4 " Expand to 4 spaces
set softtabstop=4 " Delete spaces like tabs
set shiftwidth=4 " Indent by 4 spaces
set shiftround " use multiple of shiftwidth when indenting with '<' and '>'

set noerrorbells visualbell t_vb= " No Bells

" Patterns for expand(), ctrlp, etc. to ignore
set wildignore+=log/**,node_modules/**,target/**,tmp/**,*.rbc/,.git/*,*/.hg/*,*/.svn/*
" Disable output, vcs, archive, rails, temp and backup files.
set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
set wildignore+=*.swp,*~,._*
set wildignore+=*.pyc,*__pycache__*

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
""""""" /GENERAL """""""""""""



""""""" THEMING """""""""""""
set t_Co=256 " Allows themes to display correctly
set background=dark
silent! colorscheme hybrid

" Visible white space
set list listchars=tab:▸\ ,trail:▫

"" Allow | as a cursor for neovim
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1

""""""" /THEMING """""""""""""



""""""" REMAPS """""""""""""
" Remap jk to esc. the "Smash" setting
imap jk <Esc>

" Quicker actions
nnoremap <leader>w :w<CR>

" Quicker window movement
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" Buffer navigation
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprev<CR>

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" Quick split
nnoremap <Leader>v <C-w>v<C-w>w

" Move vertically over wrapped lines
nmap j gj
nmap k gk

""""""" /REMAPS """""""""""""



""""""" Languages """""""""""""
augroup configgroup
  autocmd!
  " rst
  autocmd BufNewFile,BufRead *.txt setlocal ft=rst
  autocmd FileType rst setlocal wrap nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
  \ formatoptions+=nqtl
  " markdown
  autocmd BufRead,BufNewFile *.md set filetype=markdown
  " autocmd FileType markdown setlocal wrap nolist expandtab lbr shiftwidth=4 tabstop=4 softtabstop=4
  \ formatoptions+=nqtl
  " vim
  autocmd FileType vim setlocal shiftwidth=2 tabstop=2 softtabstop=2
  " commit messages
  autocmd Filetype gitcommit setlocal nolist textwidth=72
augroup END

""""""" /Languages """""""""""""
