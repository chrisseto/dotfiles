-- TODO: Figure out how to move this into actual lua
-- From: https://github.com/ngalaiko/tree-sitter-go-template
vim.cmd([[ autocmd BufNewFile,BufRead * if search('{{.\+}}', 'nw') | setlocal filetype=gotmpl | endif ]])
