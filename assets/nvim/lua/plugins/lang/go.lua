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
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				gopls = {},
			},
		},
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup({
				luasnip = true,
			})
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},
}
