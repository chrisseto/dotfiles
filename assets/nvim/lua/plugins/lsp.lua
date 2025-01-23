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
	-- Borrowed from https://www.lazyvim.org/plugins/lsp#nvim-lspconfig
	-- / https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua
	{
		'neovim/nvim-lspconfig',
		-- event = "LazyFile", See https://github.com/LazyVim/LazyVim/discussions/1583
		event = { "BufReadPost", "BufWritePost", "BufNewFile" },
		dependencies = {
			"mason.nvim",
			{
				"williamboman/mason-lspconfig.nvim",
				config = function()
				end
			},
			'hrsh7th/cmp-nvim-lsp',
		},
		opts = function(_, _opts)
			return {
				servers = {},
			}
		end,
		config = function(_, opts)
			local servers = opts.servers
			local cmp_nvim_lsp = require("cmp_nvim_lsp")

			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				cmp_nvim_lsp.default_capabilities(),
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
		config = function()
		end
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
			{ 'K',         mode = { 'n' }, function() vim.lsp.buf.hover() end,  desc = 'LSP hover' },
			{ '<leader>F', mode = { 'n' }, function() vim.lsp.buf.format() end, desc = 'LSP format file' },
			{
				'<leader>F',
				mode = { 'v' },
				function() vim.lsp.buf.range_formatting() end,
				desc =
				'LSP format range'
			},
			{ '<leader>rn', mode = { 'n' }, function() require('navigator.rename').rename() end, desc = 'LSP rename' },
		},
	},
	{
		"ray-x/lsp_signature.nvim",
		event = "VeryLazy",
		opts = {},
		config = function(_, opts) require 'lsp_signature'.setup(opts) end
	},
	-- Autocompletion, recommended by neovim's LSP
	{ 'hrsh7th/cmp-buffer' },
	{ 'hrsh7th/cmp-cmdline' },
	{ 'hrsh7th/cmp-nvim-lsp' },
	{ 'hrsh7th/cmp-nvim-lsp-signature-help' },
	{ 'hrsh7th/cmp-path' },
	{ 'saadparwaiz1/cmp_luasnip' },
	{
		-- TODO setup blink.
		-- https://github.com/Saghen/blink.cmp
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-path',
			-- 'PaterJason/cmp-conjure',
			'saadparwaiz1/cmp_luasnip',
		},
		config = function()
			local cmp = require('cmp')
			local luasnip = require('luasnip')

			local has_words_before = function()
				unpack = unpack or table.unpack
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0 and
					vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
			end

			cmp.setup({
				preselect = cmp.PreselectMode.None, -- Don't preselect items.
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end
				},
				mapping = {
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
							-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
							-- they way you will only jump inside the snippet region
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({ select = false }),
					-- ["<CR>"] = cmp.mapping({
					-- 	i = function(fallback)
					-- 		if cmp.visible() and cmp.get_active_entry() then
					-- 			cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
					-- 		else
					-- 			fallback()
					-- 		end
					-- 	end,
					-- 	s = cmp.mapping.confirm({ select = true }),
					-- 	c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
					-- }),
				},
				sources = cmp.config.sources({
					-- { name = 'conjure' },
					{ name = 'luasnip' },
					{ name = 'nvim_lsp' },
					{ name = 'nvim_lsp_signature_help' },
				}, {
					{ name = 'buffer' },
				}),
			})

			-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline {
					['<CR>'] = cmp.config.disable, -- TODO mappings for : don't seem to override globally specified mappings?
				},
				sources = cmp.config.sources({
					{ name = 'path' }
				}, {
					{ name = 'cmdline' }
				})
			})
		end
	},
}
