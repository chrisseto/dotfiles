vim.cmd[[
	" Better leader key
	let mapleader = "\<Space>"

	call plug#begin(stdpath('data') . '/plugged')
	" Generic lua deps
	Plug 'nvim-lua/popup.nvim'
	Plug 'nvim-lua/plenary.nvim'
	" Cute icons for various plugins
	Plug 'nvim-tree/nvim-web-devicons'
	" Delve integration
	Plug 'sebdah/vim-delve'
	" Color scheme
	Plug 'sainnhe/everforest'
	" Autocompletion, recommended by neovim's LSP
	Plug 'hrsh7th/cmp-buffer'
	Plug 'hrsh7th/cmp-nvim-lsp'
	Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
	Plug 'hrsh7th/cmp-path'
	Plug 'hrsh7th/cmp-vsnip'
	Plug 'hrsh7th/nvim-cmp'
	Plug 'hrsh7th/vim-vsnip'
	" Simple commenting
	Plug 'tpope/vim-commentary'
	" Make Tmux panes not pains
	Plug 'christoomey/vim-tmux-navigator'
	" Treesitter is a better syntax highlighter for neovim.
	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	" Native neovim LSP integration.
	Plug 'neovim/nvim-lspconfig'
	" LSP installation help
	Plug 'williamboman/mason.nvim'
	Plug 'williamboman/mason-lspconfig.nvim'
	" LSP helper
	Plug 'glepnir/lspsaga.nvim'
	" NERDTree provides a file browser
	Plug 'scrooloose/nerdtree'
	" Telescope, FZF like browsing/grepping etc
	Plug 'nvim-telescope/telescope.nvim'
	" Telescope sorter, FZF C implementation for better performance.
	Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
	" Elixir support (Mostly useful for FT detection)
	Plug 'elixir-editors/vim-elixir'
	" Git diff info + blame support
	Plug 'lewis6991/gitsigns.nvim'
	" Support yanking to system clipboards across SSH
	Plug 'ojroques/nvim-osc52'
	" Git conflict helper
	Plug 'akinsho/git-conflict.nvim'
	" Initialize plugin system
	call plug#end()
]]

require('osc52').setup{
  max_length = 0,      -- Maximum length of selection (0 for no limit)
  silent     = true,  -- Disable message on successful copy
  trim       = false,  -- Trim surrounding whitespaces before copy
}

-- Configure yanking to also copy to the system clipboard via OSC
function copy()
  if vim.v.event.operator == 'y' and vim.v.event.regname == '' then
    require('osc52').copy_register('')
  end
end

vim.api.nvim_create_autocmd('TextYankPost', {callback = copy})

-- Treesitter configuration
require'nvim-treesitter.configs'.setup {
	-- Install all syntax modules that have maintainers.
	ensure_installed = "all",

	auto_install = true,

	highlight = {
		enable = true,
		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},

	-- Enabled TS powered indentation.
	indent = {
	-- too buggy for use just yet :[
	-- enable = true
	}
}

require('gitsigns').setup()
require('git-conflict').setup()

-- LSP configuration
-- For language server specifics, see: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
vim.cmd[[
	set completeopt=menu,menuone,noselect
]]

local has_words_before = function()
  unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp = require'cmp'
cmp.setup({
	snippet = {
	  expand = function(args)
		vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
	  end,
	},
	mapping = {
		["<Tab>"] = cmp.mapping(function(fallback)
		  if cmp.visible() then
			cmp.select_next_item()
		  elseif vim.fn["vsnip#available"](1) == 1 then
			feedkey("<Plug>(vsnip-expand-or-jump)", "")
		  elseif has_words_before() then
			cmp.complete()
		  else
			fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
		  end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function()
		  if cmp.visible() then
			cmp.select_prev_item()
		  elseif vim.fn["vsnip#jumpable"](-1) == 1 then
			feedkey("<Plug>(vsnip-jump-prev)", "")
		  end
		end, { "i", "s" }),
	  ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
		{ name = 'buffer' },
		{ name = 'nvim_lsp_signature_help' },
	}),
})

-- Use an on_attach function to only map the following keys 
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap("n", "<space>F", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
end

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = {"gopls"}
})

require("mason-lspconfig").setup_handlers {
function (server_name)
	local capabilities = require('cmp_nvim_lsp').default_capabilities()
   require("lspconfig")[server_name].setup {
		on_attach = on_attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 50,
			allow_incremental_sync = true,
		},
		settings = {
			gopls = {
				directoryFilters = {"-console/node_modules", "-node_modules"},
				linksInHover = false,
				allowImplicitNetworkAccess = true,
				codelenses = {
					tidy = false,
					vendor = false,
					upgrade_dependency = false
				}
			}
		},
	   }
end,
}

require("lspsaga").setup({
	symbol_in_winbar = {
		enable = false, -- Cute but very slow.
	},
	lightbulb = {
		enable = false, -- lightbulb just gets in the way.
	},
})
local keymap = vim.keymap.set

-- Toggle outline
keymap("n","<leader>o", "<cmd>Lspsaga outline<CR>")
-- Hover Doc
keymap("n", "K", "<cmd>Lspsaga hover_doc<CR>")
-- Rename symbol
keymap("n", "<leader>rn", "<cmd>Lspsaga rename ++project<CR>")
-- /LSP configuration

vim.cmd[[
	""""" NERDTree configuration """"
	nnoremap <leader>d :NERDTreeToggle<CR>
	nnoremap <leader>D :NERDTreeFind<CR>
	let g:NERDTreeRepsectWildIgnore = 1
	""""" /NERDTree configuration """"
]]

-- Telescope configuration
require("telescope").setup {
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  }
}

require("telescope").load_extension("fzf")

-- Keymappings
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
-- /Telescope configuration

-- TODO convert to lua.
vim.cmd[[
	" Yanks to the system clipboard
	set clipboard=unnamed
	" Faster saving
	nnoremap <leader>w :w<CR>
	" Remap jk to esc. the "Smash" setting
	imap jk <Esc>
	" Toggle comments with space-/
	nmap <leader>/ gcc
	vmap <leader>/ gc
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
	nmap j gj
	nmap k gk

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
]]

-- Persistent undo
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

-- See https://github.com/sainnhe/everforest/blob/master/doc/everforest.txt
vim.g.everforest_background = 'medium'
vim.g.everforest_enable_italic = 1
vim.g.everforest_better_performance = 1
vim.g.everforest_disable_italic_comment = 1

-- TODO convert to lua.
vim.cmd[[
	" Better colors
	set termguicolors
	colorscheme everforest

	" Visible white space
	set list listchars=tab:▸\ ,trail:▫

	" No Bells
	set noerrorbells visualbell t_vb=
]]
