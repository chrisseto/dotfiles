"""" Denite and Friends """"""

map <C-p> :Denite file_rec<CR>
map <C-b> :Denite buffer<CR>
nnoremap <leader>f :Denite grep -no-empty<CR>
nnoremap <leader>h :Denite help<CR>
nnoremap <leader>c :Denite colorscheme<CR>

call denite#custom#var('file_rec', 'command',
\ ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

" Ag command on grep source
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts',
		\ ['--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

"execute ':Denite -no-empty'

" Change mappings.
call denite#custom#map(
      \ 'insert',
      \ '<C-j>',
      \ '<denite:move_to_next_line>',
      \ 'noremap'
      \)
call denite#custom#map(
      \ 'insert',
      \ '<C-k>',
      \ '<denite:move_to_previous_line>',
      \ 'noremap'
      \)

" Make highlight actually readable
call denite#custom#option('_', {
      \ 'highlight_mode_insert': 'Search'
      \ })

" Add custom menus
let s:menus = {}

let s:menus.dotfiles = {
  \ 'description': 'Edit your import configuration files'
  \ }
let s:menus.dotfiles.file_candidates = [
  \ ['neovim', '~/.config/nvim/init.vim']
  \ ]

let s:menus.git = {
  \ 'description': 'Git Commands'
  \ }
let s:menus.git.command_candidates = [
  \ ['Commit', 'Gcommit'],
  \ ['Blame', 'Gblame'],
  \ ['Status', 'Gstatus']
  \ ]

call denite#custom#var('menu', 'menus', s:menus)

call denite#initialize() " Faster start up
