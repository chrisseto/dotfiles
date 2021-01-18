" Configurations for various file types/languages

"""""" Plugins """"""

" Async linter
Plug 'w0rp/ale'
" Linters will be assigned on a per language basis
let g:ale_fixers = {}
let g:ale_linters = {}
" let g:ale_fix_on_save = 1
let g:ale_lint_on_text_changed = 'never'  " Only lint on save
let g:ale_sign_error = '⨉'
let g:ale_sign_warning = '⚠'
let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '']

" Autocomplete
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
let g:deoplete#enable_at_startup = 1
set completeopt-=preview  " Don't open the preview window
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Snippets
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
let g:neosnippet#enable_completed_snippet = 1
"""""" /Plugins """"""


"""""" Python """"""
Plug 'zchee/deoplete-jedi'
let g:ale_linters.python = ['flake8']
let g:python_host_prog = $HOME.'/.pyenv/versions/2.7.16/bin/python'
let g:python3_host_prog= $HOME.'/.pyenv/versions/3.7.4/bin/python'
" let g:deoplete#sources#jedi#show_docstring = 0
" let g:deoplete#sources#jedi#show_docstring_sig = 0
" set completeopt+=noinsert
"""""" /Python """"""

"""""" Javascript """"""
Plug 'mxw/vim-jsx'
Plug 'wokalski/autocomplete-flow'

let g:ale_fixers.javascript = ['eslint']
let g:ale_linters.javascript = ['eslint']
" let g:ale_linters.javascript = ['prettier', 'eslint']
autocmd FileType javascript.jsx  setlocal
      \ tabstop=4
      \ shiftwidth=4
"""""" /Javascript """"""


"""""" Golang """"""
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

" Plug 'fatih/vim-go'
" Plug 'zchee/deoplete-go', { 'do': 'make'}
" let g:deoplete#sources#go#gocode_binary = $GOPATH.'/bin/gocode'

" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1

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


"""""" RDF """"""
Plug 'niklasl/vim-rdf'
"""""" /RDF """"""


"""""" Hashicorp Stuff """"""
Plug 'hashivim/vim-terraform'
"""""" /Hashicorp Stuff """"""


"""""" Kotlin """"""
Plug 'udalov/kotlin-vim'
"""""" /Kotlin """"""


"""""" Swift """"""
Plug 'keith/swift.vim'
" Plug 'landaire/deoplete-swift'
"""""" /Swift """"""
