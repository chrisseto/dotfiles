vim.lsp.enable({ "terraform" })

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "hcl", "terraform" },
		},
	},
}
