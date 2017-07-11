""""""" GENERAL """""""""""""
set clipboard=unnamed " Make yanks work with system clipboard

nnoremap <leader>w :w<CR> " Faster saving

" Toggle comment with space-/
nmap <leader>/ gcc
vmap <leader>/ gc

" Move vertically over wrapped lines
nmap j gj
nmap k gk

" Remap jk to esc. the "Smash" setting
imap jk <Esc>

" in case you forgot to sudo
cnoremap w!! %!sudo tee > /dev/null %

" Remove trailing whitespace on <space><space>w
nnoremap <leader><leader>w :%s/\s\+$//<cr>:let @/=''<CR>

" Buffer navigation
nnoremap <silent> <Right> :bnext<CR>
nnoremap <silent> <Left> :bprev<CR>
nnoremap <silent> X :BW<CR>

" Persistent undo
if exists("+undofile")
" undofile - This allows you to use undos after exiting and restarting
" This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence
  if isdirectory($HOME . '/.config/nvim/undo') == 0
    :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo// undodir+=~/.config/nvim/undo// undofile
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

" Look and feel

set background=dark
let g:hybrid_custom_term_colors = 1
silent! colorscheme hybrid
" Visible white space
set list listchars=tab:▸\ ,trail:▫
set noerrorbells visualbell t_vb= " No Bells
