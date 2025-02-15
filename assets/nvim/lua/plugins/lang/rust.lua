return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "rust", "ron", "toml" } },
	},
	{
		"williamboman/mason.nvim",
		opts = { ensure_installed = { "rust-analyzer" } },
	},
	{
		'neovim/nvim-lspconfig',
		opts = {
			setup = {
				rust_analyzer = function()
					return true
				end,
			},
		},
	},
	{
		'mrcjkb/rustaceanvim',
		version = '^5', -- Recommended
		lazy = false, -- This plugin is already lazy
		ft = { "rust" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"williamboman/mason-lspconfig.nvim",
			"williamboman/mason.nvim",
		},
		opts = {
			server = {
				default_settings = {
					-- rust-analyzer language server configuration
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
							loadOutDirsFromCheck = true,
							buildScripts = {
								enable = true,
							},
						},
						-- Add clippy lints for Rust.
						checkOnSave = true,
						procMacro = {
							enable = true,
							ignored = {
								["async-trait"] = { "async_trait" },
								["napi-derive"] = { "napi" },
								["async-recursion"] = { "async_recursion" },
							},
						},
					},
				},
			},
		},
		config = function(_, opts)
			vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})
		end
	},
}
