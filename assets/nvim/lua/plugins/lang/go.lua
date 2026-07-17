vim.lsp.enable({ "gopls", "templ" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "templ",
	callback = function()
		vim.treesitter.start()
	end,
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"templ",
				"go",
				"gomod",
				"gosum",
				"gowork",
			},
			parser_config = {
				gotmpl = {
					install_info = {
						url = "https://github.com/ngalaiko/tree-sitter-go-template",
						files = { "src/parser.c" },
					},
					filetype = "gotmpl",
					used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" },
				},
			},
		},
	},
	-- Delve integration
	{ "sebdah/vim-delve" },
}
