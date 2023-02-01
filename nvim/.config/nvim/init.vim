" Better leader key
let mapleader = "\<Space>"

call plug#begin(stdpath('data') . '/plugged')
" Generic lua deps
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" Delve integration
Plug 'sebdah/vim-delve'
" A collection of colorschemes.
Plug 'rafamadriz/neon'
Plug 'marko-cerovac/material.nvim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
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
Plug 'williamboman/nvim-lsp-installer'
" NERDTree provides a file browser
Plug 'scrooloose/nerdtree'
" Telescope, FZF like browsing/grepping etc
Plug 'nvim-telescope/telescope.nvim'
" Elixir support (Mostly useful for FT detection)
Plug 'elixir-editors/vim-elixir'
" Git diff info + blame support
Plug 'lewis6991/gitsigns.nvim'
" Support yanking to system clipboards across SSH
Plug 'ojroques/vim-oscyank'
" Initialize plugin system
call plug#end()

" Configure yanking to also copy to the system clipboard via OSC
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

""""" Treesitter configuration """"
lua <<EOF
require'nvim-treesitter.configs'.setup {
	-- Install all syntax modules that have maintainers.
	ensure_installed = "maintained",

	highlight = {
		enable = true,
	},

	-- Enabled TS powered indentation.
	indent = {
	-- too buggy for use just yet :[
	-- enable = true
	}
}
EOF
""""" /Treesitter configuration """"

""""" Git integration configuration """"
lua require('gitsigns').setup()
""""" /Git integration configuration """"

""""" LSP configuration """"

set completeopt=menu,menuone,noselect

lua <<EOF
-- LSP configuration
-- For language server specifics, see: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md
local cmp = require'cmp'

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

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
	  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	},
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'vsnip' },
		{ name = 'buffer' },
		{ name = 'nvim_lsp_signature_help' },
	}),
})

local lsp_installer = require("nvim-lsp-installer")

-- Use an on_attach function to only map the following keys 
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  -- Mappings.
  local opts = { noremap=true, silent=true }

  -- See `:help vim.lsp.*` for documentation on any of the below functions
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap("n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end

lsp_installer.on_server_ready(function(server)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

	local config = {
		on_attach = on_attach,
		capabilities = capabilities,
		flags = {
			debounce_text_changes = 50,
			allow_incremental_sync = true,
		},
	}

	if server.name == "gopls" then
		config.settings = {
			gopls = {
				exec = {"crlfmt"},
				directoryFilters = {"-console/node_modules", "-node_modules"},
				linksInHover = false,
				allowImplicitNetworkAccess = true,
				codelenses = {
					tidy = false,
					vendor = false,
					upgrade_dependency = false
				}
			}
		}
	end

	server:setup(config)
end)
EOF
""""" /LSP configuration """"

""""" NERDTree configuration """"
nnoremap <leader>d :NERDTreeToggle<CR>
nnoremap <leader>D :NERDTreeFind<CR>
let g:NERDTreeRepsectWildIgnore = 1
""""" /NERDTree configuration """"

""""" Telescope configuration """"
nnoremap <silent> <C-p> <cmd>lua require('telescope.builtin').find_files()<cr>
nnoremap <leader>f <cmd>lua require('telescope.builtin').live_grep()<cr>
nnoremap <leader>fb <cmd>lua require('telescope.builtin').buffers()<cr>
nnoremap <leader>fh <cmd>lua require('telescope.builtin').help_tags()<cr>
""""" /Telescope configuration """"


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


lua <<EOF
-- Persistent undo
vim.opt.undodir = vim.fn.stdpath("cache") .. "/undo"
vim.opt.undofile = true

vim.g.neon_style = "doom"
vim.g.neon_italic_comment = false
--vim g.tokyonight_italic_comments = false
--vim.cmd[[colorscheme neon]]
vim.g.tokyonight_italic_keywords = false
vim.g.tokyonight_italic_keywords = false
vim.cmd[[colorscheme neon]]
EOF

" Better colors
set termguicolors
" Visible white space
set list listchars=tab:▸\ ,trail:▫
" No Bells
set noerrorbells visualbell t_vb=

" Plug 'airblade/vim-gitgutter'
" Plug 'itchyny/lightline.vim' " Minimal status bar
" Plug 'itchyny/vim-cursorword' " Underlines the word under your cursor
" Plug 'junegunn/seoul256.vim' " More colors
" Plug 'qpkorr/vim-bufkill'
" Plug 'rstacruz/vim-opinion'
" Plug 'tpope/vim-repeat'
" Plug 'tpope/vim-sensible'
" Plug 'tpope/vim-surround'
" Plug 'tpope/vim-unimpaired'

" " Git support
" Plug 'tpope/vim-fugitive'
" nmap <Leader>gb :Gblame<CR>
