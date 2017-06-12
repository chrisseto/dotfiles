Plug 'w0rp/ale'  " Async linter

let g:ale_linters = {
  \ 'python': ['flake8'],
  \ 'javascript': ['eslint'],
\}

let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '']

let g:ale_lint_on_text_changed = 'never'  " Only lint on save

let g:ale_sign_error = '⨉'
let g:ale_sign_warning = '⚠'
