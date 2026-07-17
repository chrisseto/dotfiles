return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "gherkin" },
			parser_config = {
				gherkin = {
					install_info = {
						url = "https://github.com/chrisseto/tree-sitter-gherkin",
						branch = "master",
						files = { "src/parser.c" },
					},
					filetype = "cucumber",
				},
			},
		},
	},
}
