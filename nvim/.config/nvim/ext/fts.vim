" Configurations for various file types/languages

"""""" Plugins """"""

" Async linter
Plug 'w0rp/ale'
" Linters will be assigned on a per language basis
let g:ale_linters = {}
let g:ale_lint_on_text_changed = 'never'  " Only lint on save
let g:ale_sign_error = '⨉'
let g:ale_sign_warning = '⚠'
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '']

" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
set completeopt-=preview  " Don't open the preview window
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

"""""" /Plugins """"""


"""""" Python """"""
Plug 'zchee/deoplete-jedi'
let g:ale_linters.python = ['flake8']
let g:python_host_prog = '/usr/local/bin/python'
let g:python3_host_prog = '/usr/local/bin/python3'
" let g:deoplete#sources#jedi#show_docstring = 0
" let g:deoplete#sources#jedi#show_docstring_sig = 0
" set completeopt+=noinsert
"""""" /Python """"""

"""""" Javascript """"""
Plug 'mxw/vim-jsx'
let g:ale_linters.javascript = ['eslint']
"""""" /Javascript """"""


"""""" Golang """"""
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', { 'do': 'make'}
autocmd FileType go setlocal
      \ autoindent
      \ noexpandtab
      \ tabstop=4
      \ shiftwidth=4
"""""" /Golang """"""


"""""" Markdown """"""
Plug 'godlygeek/tabular'
Plug 'plasticboy/vim-markdown'
autocmd FileType markdown setlocal conceallevel=2
"""""" /Markdown """"""


"""""" Rust """"""
Plug 'rust-lang/rust.vim'
Plug 'sebastianmarkow/deoplete-rust'
let g:deoplete#sources#rust#racer_binary='$HOME/.cargo/bin/racer'
let g:deoplete#sources#rust#rust_source_path = '$HOME/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src'
"""""" /Rust """"""
