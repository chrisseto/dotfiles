-- Bootstrap lazy.nvim ala https://lazy.folke.io/installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set <Space> as a more ergonomic leader key.
-- NOTE: MUST be done before anything else to ensure that key mappings get setup as expect.
-- TODO: Might be interesting to have multiple leaders to make certain keyhooks work.
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- TODO continue "borrowing" plugins from https://www.lazyvim.org/plugins/coding
-- Flit or Leap seem worthwhile https://www.lazyvim.org/plugins/editor#flitnvim
-- https://github.com/folke/trouble.nvim
-- https://www.lazyvim.org/plugins/editor#todo-commentsnvim
-- https://www.lazyvim.org/plugins/ui#bufferlinenvim
-- https://www.lazyvim.org/plugins/ui#lualinenvim
-- https://www.lazyvim.org/plugins/ui#miniindentscope
-- https://github.com/folke/neoconf.nvim
-- https://github.com/folke/persistence.nvim
require("lazy").setup({
	{ import = "plugins" },
	{ import = "plugins.lang" },
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 300
		end,
		tag = "v3.10.0", -- Pinned until https://github.com/folke/which-key.nvim/issues/809 is resolved.
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		},
	},
	{
		"neanias/everforest-nvim",
		version = false,
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			require("everforest").setup({})
			vim.o.background = "dark"
			vim.cmd([[colorscheme everforest]])
		end,
	},
	{
		"romgrk/barbar.nvim",
		dependencies = {
			"lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
			"nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
		},
		init = function()
			vim.g.barbar_auto_setup = false
		end,
		opts = {
			-- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
			-- animation = true,
			-- insert_at_start = true,
			-- …etc.
		},
		version = "^1.0.0", -- optional: only update when a new 1.x version is released
	},
	{
		"ibhagwan/fzf-lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			local fzf_lua = require("fzf-lua")

			fzf_lua.setup({})

			vim.keymap.set("n", "<C-p>", fzf_lua.files, { desc = "Files" })
			vim.keymap.set("n", "<leader>f", fzf_lua.live_grep, { desc = "Live Search" })
			vim.keymap.set("n", "<leader>g", fzf_lua.git_status, { desc = "Modified Files" })
		end,
	},
	-- Git diff info + blame support.
	{ "lewis6991/gitsigns.nvim", config = true },
	-- Multiplexer navigation
	{
		"mrjones2014/smart-splits.nvim",
		lazy = false,
		config = function()
			local ss = require("smart-splits")

			ss.setup({
				disable_multiplexer_nav_when_zoomed = false,
			})

			vim.keymap.set("n", "<C-h>", ss.move_cursor_left)
			vim.keymap.set("n", "<C-j>", ss.move_cursor_down)
			vim.keymap.set("n", "<C-k>", ss.move_cursor_up)
			vim.keymap.set("n", "<C-l>", ss.move_cursor_right)
		end,
	},
	-- Elixir support (Mostly useful for FT detection)
	{ "elixir-editors/vim-elixir" },
	-- Helper for Comment.nvim
	{ "JoosepAlviste/nvim-ts-context-commentstring" },

	{
		-- Comment toggler powered by treesitter and friends
		"numToStr/Comment.nvim",
		dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
			})

			require("Comment.ft").set("scad", "//%s")
		end,
	},
	{
		-- Support yanking to system clipboards across SSH
		"ojroques/nvim-osc52",
		config = function()
			require("osc52").setup({
				max_length = 0, -- Maximum length of selection (0 for no limit)
				silent = true, -- Disable message on successful copy
				trim = false, -- Trim surrounding whitespaces before copy
			})

			-- Configure yanking to also copy to the system clipboard via OSC
			local function copy()
				if vim.v.event.operator == "y" and vim.v.event.regname == "" then
					require("osc52").copy_register("")
				end
			end

			vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
		end,
	},

	{
		-- NERDTree provides a file browser
		-- TODO: Consider replacing with https://github.com/nvim-neo-tree/neo-tree.nvim
		"scrooloose/nerdtree",
		config = function()
			vim.cmd([[ let g:NERDTreeRepsectWildIgnore = 1 ]])
		end,
		lazy = false,
		keys = {
			{ "<leader>d", ":NERDTreeToggle<CR>", desc = "Toggle File Tree" },
			{ "<leader>D", ":NERDTreeFind<CR>", desc = "Find in File Tree" },
		},
	},

	{
		"L3MON4D3/LuaSnip",
		version = "2.*",
		build = "make install_jsregexp",
		config = function()
			-- TODO lua snippets seem ripe for a fennel integration.

			-- See https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#config-options
			require("luasnip").setup({
				update_events = { "TextChanged", "TextChangedI" },
			})

			require("luasnip.loaders.from_lua").lazy_load({
				paths = { "./lua/snippets", "./lua/snips" },
			})
		end,
		keys = {
			{
				"<leader>es",
				function()
					require("luasnip.loaders").edit_snippet_files()
				end,
				"n",
				desc = "Edit Snippets",
			},
		},
	},
	-- Useful for debugging/exploring how treesitter actually parses a document.
	{ "nvim-treesitter/playground" },
	-- Treesitter is a better syntax highlighter for neovim.
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		opts_extend = { "ensure_installed" },
		opts = {
			auto_install = true,
			ensure_installed = {
				"lua",
				"markdown",
				"python",
				"terraform",
				"vim",
			},

			highlight = {
				enable = true,
				-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
				-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
				-- Using this option may slow down your editor, and you may see some duplicate highlights.
				-- Instead of true it can also be a list of languages
				additional_vim_regex_highlighting = false,
			},

			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "gnn", -- set to `false` to disable one of the mappings
					node_incremental = "grn",
					scope_incremental = "grc",
					node_decremental = "grm",
				},
			},

			-- Enable TS powered indentation.
			indent = {
				-- too buggy for use just yet :[
				-- enable = true
			},

			playground = {
				enable = true,
			},
		},
	},
	{
		"kevinhwang91/nvim-ufo",
		dependencies = { "kevinhwang91/promise-async" },
		config = function()
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true

			-- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
			vim.keymap.set("n", "zR", require("ufo").openAllFolds)
			vim.keymap.set("n", "zM", require("ufo").closeAllFolds)

			require("ufo").setup({
				provider_selector = function(bufnr, filetype, buftype)
					return { "treesitter", "indent" }
				end,
			})
		end,
	},
	{
		-- Easily open a file on GitHub for sharing. Defaults to the branch and falls back to the commit.
		-- Kinda slow but better than manually searching.
		"almo7aya/openingh.nvim",
		keys = {
			{ "gog", "<cmd>OpenInGHFile<cr>", mode = "n", desc = "Open In GitHub" },
			{ "gog", "<cmd>OpenInGHFileLines<cr>", mode = "v", desc = "Open In GitHub" },
		},
	},
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim", -- required
			"sindrets/diffview.nvim", -- optional - Diff integration
			"ibhagwan/fzf-lua", -- optional
		},
	},

	-- TODO switch to which-key.nvim instead.
	{
		"mrjones2014/legendary.nvim",
		dependencies = { "kkharji/sqlite.lua" },
		config = function()
			local h = require("legendary.toolbox")

			-- TODO write a custom formatter. Works great but looks like trash and feels backwards.
			-- TODO Might be worth to just switch to which-key.nvim and then look for something to bolt on top. Then I get to use lazy's keymapping features.
			require("legendary").setup({
				keymaps = {
					{
						"<leader>/",
						{ n = "gcc", v = "gc" },
						description = "Toggle Comment",
						opts = { remap = true },
					},
					{ "<leader>t", ":Trouble<CR>", description = "Toggle Trouble List" },
					{ "<leader>l", ":Legendary<CR>", description = "Legendary" },
				},
			})
		end,
	},
}, {
	change_detection = {
		enabled = false,
	},
})

-- Persistent undo
-- TODO use persitent.nvim?
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

-- TODO convert to lua.
vim.cmd([[
	set spell
	set spelllang=en,cjk
	set spellsuggest=best,9

	" Yanks to the system clipboard
	set clipboard=unnamed
	" Faster saving
	nnoremap <leader>w :w<CR>
	" Remap jk to esc. the "Smash" setting
	imap jk <Esc>
	" Only insert one space between sentences when wrapping comments
	set nojoinspaces
	" Don't wrap lines by default
	set nowrap
	" Only expand tabs to 4 spaces. Defaults to 8 which is too much.
	set tabstop=4
	set shiftwidth=4
	" search case insensitively until a capital becomes present.
	set ignorecase
	set smartcase
	" Move vertically over wrapped lines
	nnoremap j gj
	nnoremap k gk

	" Show line numbers
	set number
	" Use smart case searching
	set smartcase
	" Make sure Vim returns to the same line when you reopen a file.
	" TODO: There's gotta be a better way to handle this at this point.
	augroup line_return
		au!
		au BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\     execute 'normal! g`"zvzz' |
			\ endif
	augroup END

	" Visible white space
	set list listchars=tab:▸\ ,trail:▫

	" No Bells
	set noerrorbells visualbell t_vb=
]])
