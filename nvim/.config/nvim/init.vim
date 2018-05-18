" Better leader key
let mapleader = "\<Space>"

call plug#begin('~/.config/nvim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator' " Make Tmux panes not pains
Plug 'flazz/vim-colorschemes' " Make things looks acceptable
Plug 'itchyny/lightline.vim' " Minimal status bar
Plug 'itchyny/vim-cursorword' " Underlines the word under your cursor
Plug 'junegunn/seoul256.vim' " More colors
Plug 'qpkorr/vim-bufkill'
Plug 'rstacruz/vim-opinion'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-commentary' " Simple commenting
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'

Plug 'Shougo/denite.nvim', { 'merged' : 0, 'loadconf' : 1, 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neomru.vim'

Plug 'vimwiki/vimwiki'

" Per FT Configurations
execute 'source '. fnameescape('~/.config/nvim/ext/fts.vim')

" Git support
Plug 'tpope/vim-fugitive'
nmap <Leader>gb :Gblame<CR>

" NerdTree
Plug 'scrooloose/nerdtree'
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>D :NERDTreeFind<CR>
let g:NERDTreeRepsectWildIgnore = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']

" Code Focus
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'junegunn/rainbow_parentheses.vim'
nmap <Leader>l :Limelight!!<CR>
nmap <Leader>G :Goyo<CR>
nmap <Leader>r :RainbowParentheses!!<CR>
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!
let g:limelight_conceal_ctermfg = 240
let g:goyo_width = '75%'

call plug#end()

execute 'source '. fnameescape('~/.config/nvim/ext/status.vim')
execute 'source '. fnameescape('~/.config/nvim/ext/denite.vim')
execute 'source '. fnameescape('~/.config/nvim/ext/general.vim')
