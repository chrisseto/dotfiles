local function luals_config(capabilities)
	return {
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 50,
			allow_incremental_sync = true,
		},
		settings = {
			Lua = {
				-- Do not send telemetry data containing a randomized but unique identifier
				telemetry = {
					enable = false,
				},
				-- TODO Figure out how to get this working to stop the formatter from wrapping all my key mapping lines.
				config = {
					format = {
						defaultConfig = [[ max_line_length = 500 ]]
					},
				},
			}
		}
	}
end

return {
	-- Better version of lua_ls for neovim configuration.
	-- TODO: Do I need lua_ls configured?
	{ "folke/neodev.nvim", opts = {} },
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
	{
		'neovim/nvim-lspconfig',
		cmd = "LSPInfo",
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			{ 'folke/neodev.nvim' },
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

			lspconfig.lua_ls.setup(luals_config(capabilities))
		end
	},
}
