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

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "go", "gomod", "gosum", "gowork" } },
	},
	{
		'neovim/nvim-lspconfig',
		opts = {
			servers = {
				gopls = {
				},
			},
		},
	-- 	cmd = "LSPInfo",
	-- 	event = { 'BufReadPre', 'BufNewFile' },
	-- 	dependencies = {
	-- 		{ 'hrsh7th/cmp-nvim-lsp' },
	-- 	},
	-- 	config = function()
	-- 		-- To Debug LSP settings:
	-- 		-- :lua print(vim.inspect(vim.lsp.get_active_clients()))
	--
	-- 		local lspconfig = require('lspconfig')
	-- 		local capabilities = require('cmp_nvim_lsp').default_capabilities()
	-- 		capabilities.textDocument.foldingRange = {
	-- 			dynamicRegistration = false,
	-- 			lineFoldingOnly = true
	-- 		}
	--
	-- 		lspconfig.gopls.setup(gopls_config(capabilities))
	-- 	end
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
}
