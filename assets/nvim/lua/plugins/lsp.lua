return {
	{
		"hedyhli/outline.nvim",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons",
		},
		keys = {
			{ "<leader>o", ":Outline<CR>", desc = "Toggle Symbol Outline" },
		},
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = { "rafamadriz/friendly-snippets" },
		-- use a release tag to download pre-built binaries
		version = "1.*",
		opts = {
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			appearance = {
				nerd_font_variant = "mono",
			},
			completion = {
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 500,
				},
				list = {
					selection = {
						preselect = false,
					},
				},
				ghost_text = { enabled = true },
			},
			signature = { enabled = true },
		},
		cmdline = {
			enabled = true,
			keymap = {
				preset = "inherit",
				["<CR>"] = { "accept_and_enter", "fallback" },
			},
		},
	},
	-- -- Borrowed from https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
	-- -- / https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
	{
		"neovim/nvim-lspconfig",
		-- event = "LazyFile", See https://github.com/LazyVim/LazyVim/discussions/1583
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		config = function(_, opts)
			-- https://neovim.io/doc/user/lsp.html
			-- For verbose logs.
			-- vim.lsp.set_log_level 'trace'
			-- require('vim.lsp.log').set_format_func(vim.inspect)

			-- This probably doesn't belong here.
			vim.diagnostic.config({
				virtual_text = { current_line = true },
			})

			-- Set capabilities for all servers.
			vim.lsp.config("*", {
				capabilities = require("blink.cmp").get_lsp_capabilities({
					-- TODO: This doesn't work. Not sure why and there's not much documentation available.
					-- workspace = {
					-- 	didChangeWatchedFiles = {
					-- 		dynamicRegistration = true,
					-- 	},
					-- },
				}),
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)

					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
					vim.keymap.set("n", "gD", vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { buffer = bufnr, desc = "Get implementations" })
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
					vim.keymap.set("n", "<leader>F", vim.lsp.buf.format, { buffer = bufnr, desc = "LSP format file" })
					vim.keymap.set("v", "<leader>F", vim.lsp.buf.format, { buffer = bufnr, desc = "LSP format selection" })
					vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr, desc = "Show references" })
					vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = bufnr })
				end,
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/nvim-web-devicons" },
		---@module 'render-markdown'
		---@type render.md.UserConfig
		opts = {
			heading = {
				sign = false,
			},
		},
	},
	{
		"mason-org/mason.nvim",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = { "shfmt" },
		},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
	},
}
