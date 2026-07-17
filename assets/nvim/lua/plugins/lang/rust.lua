vim.lsp.enable({ "rust-analyzer" })

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = {
				"rust",
				"ron",
				"toml",
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts = { ensure_installed = { "rust-analyzer" } },
	},
}
