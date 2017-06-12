Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

let g:deoplete#enable_at_startup = 1
set completeopt-=preview  " Don't open the preview window
" deoplete tab-complete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"


" Python Autocomplete
Plug 'zchee/deoplete-jedi'
" let g:deoplete#sources#jedi#show_docstring = 0
" let g:deoplete#sources#jedi#show_docstring_sig = 0
" set completeopt+=noinsert
let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'

" Rust Autocomplete
Plug 'sebastianmarkow/deoplete-rust'
let g:deoplete#sources#rust#racer_binary='$HOME/.cargo/bin/racer'
let g:deoplete#sources#rust#rust_source_path = '$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src'

" Golang Autocomplete
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', { 'do': 'make'}
