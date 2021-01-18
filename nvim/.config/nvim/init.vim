" Better leader key
let mapleader = "\<Space>"

" Use pyenv's python installations
let g:python_host_prog = $HOME.'/.pyenv/versions/2.7.16/bin/python'
let g:python3_host_prog= $HOME.'/.pyenv/versions/3.7.4/bin/python'

call plug#begin('~/.config/nvim/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'christoomey/vim-tmux-navigator' " Make Tmux panes not pains
Plug 'flazz/vim-colorschemes' " Make things looks acceptable
Plug 'itchyny/lightline.vim' " Minimal status bar
Plug 'itchyny/vim-cursorword' " Underlines the word under your cursor
Plug 'junegunn/seoul256.vim' " More colors
Plug 'qpkorr/vim-bufkill'
Plug 'rstacruz/vim-opinion'
" Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-commentary' " Simple commenting
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'codelitt/vim-qtpl'

Plug 'sebdah/vim-delve'
Plug 'vmchale/dhall-vim'

"""""" Denite Settings """"""
Plug 'Shougo/denite.nvim', { 'merged' : 0, 'loadconf' : 1, 'do': ':UpdateRemotePlugins' }
"""""" /Denite Settings """"""

Plug 'Shougo/neomru.vim'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" gh - get hint on whatever's under the cursor
nnoremap <silent> K :call <SID>show_documentation()<CR>
nnoremap <silent> gh :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" gd - go to definition of word under cursor
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)

" gi - go to implementation
nmap <silent> gi <Plug>(coc-implementation)

" gr - find references
nmap <silent> gr <Plug>(coc-references)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

nnoremap <silent> <leader>co  :<C-u>CocList outline<cr>
nnoremap <silent> <leader>cs  :<C-u>CocList -I symbols<cr>

" view all errors
nnoremap <silent> <leader>cl  :<C-u>CocList locationlist<CR>

" rename the current word in the cursor
nmap <leader>cr  <Plug>(coc-rename)

" Plug 'vimwiki/vimwiki'

" Per FT Configurations
" execute 'source '. fnameescape('~/.config/nvim/ext/fts.vim')

" Git support
Plug 'tpope/vim-fugitive'
nmap <Leader>gb :Gblame<CR>

"""""" NerdTree """"""
Plug 'scrooloose/nerdtree'
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>D :NERDTreeFind<CR>
let g:NERDTreeRepsectWildIgnore = 1
let NERDTreeIgnore = ['\.pyc$', '__pycache__']
"""""" /NerdTree """"""

"""""" Typescript """"""
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
"""""" /Typescript """"""

"""""" Golang """"""
autocmd FileType go setlocal
      \ autoindent
      \ noexpandtab
      \ tabstop=4
      \ shiftwidth=4
"""""" Golang """"""

call plug#end()

execute 'source '. fnameescape('~/.config/nvim/ext/status.vim')
execute 'source '. fnameescape('~/.config/nvim/denite.vim')
execute 'source '. fnameescape('~/.config/nvim/general.vim')
