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
		dependencies = { "rafamadriz/friendly-snippets", },
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
				-- highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
				-- -- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- -- Useful for when your theme doesn't support blink.cmp
				-- -- Will be removed in a future release
				-- use_nvim_cmp_as_default = true,
				nerd_font_variant = 'mono'
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
	},
	-- -- Borrowed from https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
	-- -- / https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
	{
		"neovim/nvim-lspconfig",
		-- event = "LazyFile", See https://github.com/LazyVim/LazyVim/discussions/1583
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			{
				"williamboman/mason-lspconfig.nvim",
				config = function() end,
			},
		},
		opts = function(_, _opts)
			return {
				servers = {},
			}
		end,
		config = function(_, opts)
			-- For verbose logs.
			-- vim.lsp.set_log_level 'trace'
			-- require('vim.lsp.log').set_format_func(vim.inspect)

			-- Set capabilities for all servers.
			vim.lsp.config('*', {
				capabilities = require("blink.cmp").get_lsp_capabilities({}),
			})

			vim.api.nvim_create_autocmd('LspAttach', {
			  callback = function(args)
				local bufnr = args.buf
				local client = vim.lsp.get_client_by_id(args.data.client_id)

				vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = "Go to definition" })
				vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, { buffer = bufnr, desc = "Go to type definition" })
				vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = "Get implementations" })
				vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "Hover documentation" })
				vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = bufnr, desc = "Rename symbol" })
				vim.keymap.set('n', '<leader>F', vim.lsp.buf.format, { buffer = bufnr, desc = "LSP format file" })
				vim.keymap.set('v', '<leader>F', vim.lsp.buf.format, { buffer = bufnr, desc = "LSP format selection" })
				vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = "Show references"})
				vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { buffer = bufnr })
			  end,
		  })
	  end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function() end,
	},
	{
		"williamboman/mason.nvim",
		cmd = "Mason",
		-- keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
		build = ":MasonUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
			ensure_installed = {
				"stylua",
				"shfmt",
			},
		},
		---@param opts MasonSettings | {ensure_installed: string[]}
		config = function(_, opts)
			require("mason").setup(opts)
			local mr = require("mason-registry")
			mr:on("package:install:success", function()
				vim.defer_fn(function()
					-- trigger FileType event to possibly load this newly installed LSP server
					require("lazy.core.handler.event").trigger({
						event = "FileType",
						buf = vim.api.nvim_get_current_buf(),
					})
				end, 100)
			end)

			mr.refresh(function()
				for _, tool in ipairs(opts.ensure_installed) do
					local p = mr.get_package(tool)
					if not p:is_installed() then
						p:install()
					end
				end
			end)
		end,
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = {
			"kevinhwang91/promise-async",
		},
		config = function()
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			require("ufo").setup()
		end,
		keys = {
			-- Using ufo provider need remap `zR` and `zM`.
			{
				"zR",
				mode = { "n" },
				function()
					require("ufo").openAllFolds()
				end,
				desc = "Open All Folds",
			},
			{
				"zM",
				mode = { "n" },
				function()
					require("ufo").closeAllFolds()
				end,
				desc = "Close All Folds",
			},
		},
	},
	{
		"folke/trouble.nvim",
		opts = {},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},
}
