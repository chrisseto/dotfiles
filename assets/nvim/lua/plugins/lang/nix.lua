return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "nix" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				nil_ls = {
					settings = {
						['nil'] = {
							nix = {
								flake = {
									autoArchive = true,
								},
							},
						},
					},
				},
			},
		},
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "nil" } },
	}
}
