-- As of nvim 0.11, ftplugin/go.vim sets formatprg to gofmt which breaks my
-- usage of gq as a comment wrapper. As I use an LSP to handle formatting,
-- disable this altogether.
vim.bo.formatprg = ""
