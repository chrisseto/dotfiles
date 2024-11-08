local function gopls_config(capabilities)
	-- TODO gopackagesdriver helps with speed and memory but results in a lot of weird issues. Namely: 1) "pkg_test" should be "pkg" 2) "no metadata for (stdlib package)"
	return {
		capabilities = capabilities,
		flags = {
			-- debounce_text_changes = 50,
			-- allow_incremental_sync = true,
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
		-- On MacOS: `fd "(pgrep gopls).log" /var/`
		cmd = { "gopls", "serve", "--logfile=auto", "-rpc.trace" },
		settings = {
			gopls = {
				gofumpt = true,

				-- https://github.com/golang/tools/blob/master/gopls/doc/settings.md#templateextensions-string
				templateExtensions = { "gotpl" },

				-- https://github.com/golang/tools/blob/c95fa0ff4c2370b6f4b78947fc45987c8d0d664a/gopls/doc/settings.md#expandworkspacetomodule-bool
				-- I think this is what makes gopls randomly lose its shit whenever I add a new import?
				expandWorkspaceToModule = false,
				directoryFilters = {
					-- 	"-_bazel",
					-- 	"-bazel-bin",
					-- 	"-bazel-out",
					-- 	"-bazel-testlogs",
					"-**/node_modules",
				},
				-- linksInHover = false,
				-- allowImplicitNetworkAccess = true,
				-- -- May be causing issues??
				-- -- buildFlags = { "-tags=bazel" },
				-- hints = { parameterNames = true },
				-- semanticTokens = true,
				-- -- symbolScope = "workspace",
				-- codelenses = {
				-- 	gc_details = false,
				-- 	regenerate_gco = false,
				-- 	test = false,
				-- 	tidy = false,
				-- 	upgrade_dependency = false,
				-- 	vendor = false,
				-- }
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
			-- To Debug LSP settings:
			-- :lua print(vim.inspect(vim.lsp.get_active_clients()))

			local lspconfig = require('lspconfig')
			local capabilities = require('cmp_nvim_lsp').default_capabilities()
			capabilities.textDocument.foldingRange = {
				dynamicRegistration = false,
				lineFoldingOnly = true
			}

			lspconfig.gopls.setup(gopls_config(capabilities))
			lspconfig.lua_ls.setup(luals_config(capabilities))
			lspconfig.ts_ls.setup { capabilities = capabilities }
			lspconfig.openscad_lsp.setup { capabilities = capabilities }
			lspconfig.terraformls.setup { capabilities = capabilities }
			lspconfig.zls.setup { capabilities = capabilities }
			lspconfig.pyright.setup { capabilities = capabilities }
		end
	},
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		config = function()
			require("go").setup({
				luasnip = true,
			})
		end,
		event = { "CmdlineEnter" },
		ft = { "go", 'gomod' },
		build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
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
