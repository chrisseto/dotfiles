vim.lsp.enable({"gopls"})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				["go"] = true,
				["gomod"] = true,
				["gosum"] = true,
				["gowork"] = true,
			},
			parser_config = {
				gotmpl = {
					install_info = {
						url = "https://github.com/ngalaiko/tree-sitter-go-template",
						files = { "src/parser.c" },
					},
					filetype = "gotmpl",
					used_by = { "gohtmltmpl", "gotexttmpl", "gotmpl", "yaml" },
				}
			}
		},
	},
	-- Delve integration
	{ "sebdah/vim-delve" },
}
