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
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				filetypes = {
					["*"] = false, -- disable by default on all files types, I'll opt in as desired.
				},
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuOpen",
				callback = function()
					vim.b.copilot_suggestion_hidden = true
				end,
			})

			vim.api.nvim_create_autocmd("User", {
				pattern = "BlinkCmpMenuClose",
				callback = function()
					vim.b.copilot_suggestion_hidden = false
				end,
			})
		end,
		-- opts = {
		--   -- suggestion = { enabled = false },
		--   -- panel = { enabled = false },
		--   -- filetypes = {
		--   --   markdown = true,
		--   --   help = true,
		--   -- },
		-- },
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = "rafamadriz/friendly-snippets",
		-- use a release tag to download pre-built binaries
		version = "*",
		opts = {
			keymap = {
				preset = "none",
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<CR>"] = { "accept", "fallback" },

				cmdline = {
					-- When completing in cmdline
					["<CR>"] = {
						function(cmp)
							cmp.accept({
								callback = function()
									vim.api.nvim_feedkeys("\n", "n", true)
								end,
							})
						end,
						"fallback",
					},
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
			},
			appearance = {
				highlight_ns = vim.api.nvim_create_namespace("blink_cmp"),
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = true,
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
			local servers = opts.servers

			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("blink.cmp").get_lsp_capabilities(),
				opts.capabilities or {}
			)

			local function setup(server)
				local server_opts = vim.tbl_deep_extend("force", {
					capabilities = vim.deepcopy(capabilities),
				}, servers[server] or {})
				if server_opts.enabled == false then
					return
				end

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
						return
					end
				elseif opts.setup["*"] then
					if opts.setup["*"](server, server_opts) then
						return
					end
				end
				require("lspconfig")[server].setup(server_opts)
			end

			for server, server_opts in pairs(servers) do
				setup(server)
			end
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
	{
		"ray-x/guihua.lua",
		build = "cd lua/fzy && make",
	},
	{
		"ray-x/navigator.lua",
		dependencies = {
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter-refactor",
		},
		config = function()
			require("navigator").setup({
				icons = { icons = false },
				default_mapping = false, -- Disable default keymaps. We'll bind them manually.
				ts_fold = { enable = false }, -- Disable Treesitter folding. UFO does this.
			})
		end,
		-- https://github.com/ray-x/navigator.lua/blob/master/lua/navigator/lspclient/mapping.lua#L32
		keys = {
			{
				"K",
				mode = { "n" },
				function()
					vim.lsp.buf.hover()
				end,
				desc = "LSP hover",
			},
			{
				"<leader>F",
				mode = { "n" },
				function()
					vim.lsp.buf.format()
				end,
				desc = "LSP format file",
			},
			{
				"<leader>F",
				mode = { "v" },
				function()
					vim.lsp.buf.range_formatting()
				end,
				desc = "LSP format range",
			},
			{
				"<leader>rn",
				mode = { "n" },
				function()
					require("navigator.rename").rename()
				end,
				desc = "LSP rename",
			},
		},
	},
}
