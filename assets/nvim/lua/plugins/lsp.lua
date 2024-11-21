return {
	{
		'hedyhli/outline.nvim',
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},
		keys = {
			{ "<leader>o", ":Outline<CR>", desc = "Toggle Symbol Outline" },
		},
	},
	{ "williamboman/mason-lspconfig.nvim", config = function() end },
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
		'kevinhwang91/nvim-ufo',
		dependencies = {
			'kevinhwang91/promise-async',
		},
		config = function()
			vim.o.foldcolumn = '1' -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Using ufo provider need remap `zR` and `zM`.
			-- vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
			-- vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

			require('ufo').setup()
		end,
		keys = {
			{ "zR", mode = { "n" }, function() require("ufo").openAllFolds() end,  desc = "Open All Folds" },
			{ "zM", mode = { "n" }, function() require("ufo").closeAllFolds() end, desc = "Close All Folds" },
		}
	},
	{
		'folke/trouble.nvim',
		opts = {},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},
	{
		'neovim/nvim-lspconfig',
		cmd = "LSPInfo",
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			{ 'hrsh7th/cmp-nvim-lsp' },
		},
		config = function()
			-- To Debug LSP settings:
			-- :lua print(vim.inspect(vim.lsp.get_active_clients()))

			local lspconfig = require('lspconfig')
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true
			}

			lspconfig.ts_ls.setup { capabilities = capabilities }
			lspconfig.openscad_lsp.setup { capabilities = capabilities }
			lspconfig.terraformls.setup { capabilities = capabilities }
			lspconfig.zls.setup { capabilities = capabilities }
			lspconfig.pyright.setup { capabilities = capabilities }
		end
	},
	{
		"ray-x/guihua.lua",
		build = 'cd lua/fzy && make',
	},
	{
		'ray-x/navigator.lua',
		dependencies = {
			'ray-x/guihua.lua',
			'neovim/nvim-lspconfig',
			'nvim-treesitter/nvim-treesitter-refactor',
		},
		config = function()
			require 'navigator'.setup({
				icons = { icons = false },
				default_mapping = false, -- Disable default keymaps. We'll bind them manually.
				ts_fold = { enable = false }, -- Disable Treesitter folding. UFO does this.
			})
		end,
		-- https://github.com/ray-x/navigator.lua/blob/master/lua/navigator/lspclient/mapping.lua#L32
		keys = {
			{ 'K',          mode = { 'n' }, function() vim.lsp.buf.hover() end,                  desc = 'LSP hover' },
			{ '<leader>F',  mode = { 'n' }, function() vim.lsp.buf.format() end,                 desc = 'LSP format file' },
			{ '<leader>F',  mode = { 'v' }, function() vim.lsp.buf.range_formatting() end,       desc = 'LSP format range' },
			{ '<leader>rn', mode = { 'n' }, function() require('navigator.rename').rename() end, desc = 'LSP rename' },
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts) require 'lsp_signature'.setup(opts) end
	}
}
