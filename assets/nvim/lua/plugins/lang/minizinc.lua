vim.filetype.add({
	extension = {
		mzn = "minizinc",
	},
})

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "minizinc" },
			parser_config = {
				minizinc = {
					install_info = {
						url = "https://github.com/shackle-rs/shackle",
						branch = "develop",
						files = { "parsers/tree-sitter-minizinc/src/parser.c" },
					},
					filetype = "minizinc",
				},
			},
		},
	},
}
