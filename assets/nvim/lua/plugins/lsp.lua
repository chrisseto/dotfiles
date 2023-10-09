local function gopls_config(capabilities)
	-- TODO gopackagesdriver helps with speed and memory but results in a lot of weird issues. Namely: 1) "pkg_test" should be "pkg" 2) "no metadata for (stdlib package)"
	return {
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 50,
			allow_incremental_sync = true,
		},
		-- 						on_new_config = function(config, new_root_dir)
		-- 							-- -- If new_root_dir seems like a bazel project and there isn't a `.nogopackagesdriver` file, set GOPACKAGESDRIVER to a
		-- 							-- -- global script (which seems to be safe as they all contain the same contents, it just needs to exist as a file somewhere).
		-- 							-- -- https://github.com/bazelbuild/rules_go/wiki/Editor-and-tool-integration
		-- 							local packagesdriver = nil
		-- 							if vim.fn.filereadable(new_root_dir .. '/.bazelrc') == 1 and vim.fn.filereadable(new_root_dir .. '/.nogopackagesdriver') == 0 then
		-- 								packagesdriver = vim.fn.expand("~/.bin/gopackagesdriver")
		-- 							end
		--
		-- 							if config.cmd_env then
		-- 								config.cmd_env.GOPACKAGESDRIVER = packagesdriver
		-- 							else
		-- 								config.cmd_env = { GOPACKAGESDRIVER = packagesdriver }
		-- 							end

		-- For debugging add --logfile=auto and -rpc.trace. Log files will be in /tmp/gopls-[pid].log
		cmd = { "gopls", "serve" },
		settings = {
			gopls = {
				directoryFilters = {
					"-_bazel",
					"-bazel-bin",
					"-bazel-out",
					"-bazel-testlogs",
					"-**/node_modules",
				},
				linksInHover = false,
				allowImplicitNetworkAccess = true,
				-- May be causing issues??
				-- buildFlags = { "-tags=bazel" },
				hints = { parameterNames = true },
				semanticTokens = true,
				symbolScope = "workspace",
				codelenses = {
					gc_details = false,
					regenerate_gco = false,
					test = false,
					tidy = false,
					upgrade_dependency = false,
					vendor = false,
				}
			}
		}
	}
end

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
	{ "folke/neodev.nvim",             opts = {} },
	{ 'simrat39/symbols-outline.nvim', opts = {} },
	{
		'folke/trouble.nvim',
		opts = {},
		dependencies = { 'nvim-tree/nvim-web-devicons' },
	},

	-- Native neovim LSP integration.
	-- NOTE: LSP Servers are provided via nix.
	-- TODO: Consider namespacing LSP server binaries.
	{
		'neovim/nvim-lspconfig',
		cmd = "LSPInfo",
		event = { 'BufReadPre', 'BufNewFile' },
		dependencies = {
			{ 'folke/neodev.nvim' },
			{ 'hrsh7th/cmp-nvim-lsp' },
		},
		config = function()
			-- error("bar")
			-- To Debug LSP settings:
			-- :lua print(vim.inspect(vim.lsp.get_active_clients()))

			local lspconfig = require('lspconfig')
			local capabilities = require('cmp_nvim_lsp').default_capabilities()

			lspconfig.gopls.setup(gopls_config(capabilities))
			lspconfig.lua_ls.setup(luals_config(capabilities))
			lspconfig.openscad_lsp.setup { capabilities = capabilities }
			lspconfig.terraformls.setup { capabilities = capabilities }
		end
	},

	-- LSP helper (TODO Replace with simple customization and other plugins)
	{
		'glepnir/lspsaga.nvim',
		config = function()
			require("lspsaga").setup({
				symbol_in_winbar = {
					enable = false, -- Cute but very slow.
				},
				lightbulb = {
					enable = false, -- lightbulb just gets in the way.
				},
			})
		end
	},

}
