vim.lsp.enable({ "nil" })

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "nix" } },
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "nil" } },
	},
}
