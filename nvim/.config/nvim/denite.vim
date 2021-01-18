" Denite shortcuts
nnoremap <C-p> :Denite file/rec -start-filter<CR>
nnoremap <leader>f :Denite grep -no-empty<CR>
" vnoremap <leader>f :Denite grep -input=""<CR>
" \let old_reg=getreg('"')
nnoremap <leader>c :CocList<CR>

" Mappings for the Denite buffer
autocmd FileType denite call s:denite_settings()
function! s:denite_settings() abort
  nnoremap <silent><buffer><expr> <CR>
  \ denite#do_map('do_action')
  " nnoremap <silent><buffer><expr> d
  " \ denite#do_map('do_action', 'delete')
  " nnoremap <silent><buffer><expr> p
  " \ denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q
  \ denite#do_map('quit')
  " nnoremap <silent><buffer><expr> i
  " \ denite#do_map('open_filter_buffer')
  " nnoremap <silent><buffer><expr> <Space>
  " \ denite#do_map('toggle_select').'j'
endfunction

autocmd FileType denite-filter call s:denite_filter_settings()
function! s:denite_filter_settings() abort
  inoremap <silent><buffer><expr> <C-c>
        \ denite#do_map('quit')
endfunction

" Use Ag for :Denite grep
call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts',
    \ ['-i', '--vimgrep', '--ignore', 'vendor'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" Use Ag for :Denite file/rec
call denite#custom#var('file_rec', 'command',
\ ['ag', '--ignore', 'vendor', '--follow', '--nocolor', '--nogroup', '-g', ''])

let s:menus = {}
let s:menus.codelens = {
      \ 'description': 'CodeLens commands'
      \ }
let s:menus.codelens.command_candidates = [
      \ ['Go to definition', '<Plug>(coc-definition)'],
      \ ]

call denite#custom#var('menu', 'menus', s:menus)

" Faster start up
call denite#initialize()
