" Better leader key
let mapleader = "\<Space>"

call plug#begin(stdpath('data') . '/plugged')
" Generic lua deps
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
" Delve integration
Plug 'sebdah/vim-delve'
" A collection of colorschemes.
" Plug 'flazz/vim-colorschemes'
Plug 'rafamadriz/neon'
Plug 'marko-cerovac/material.nvim'
Plug 'christianchiarulli/nvcode-color-schemes.vim'
" Autocompletion, recommended by neovim's LSP
Plug 'hrsh7th/nvim-compe'
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
" Snippet support for complicated LSP completions.
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
" Git diff info + blame support
Plug 'lewis6991/gitsigns.nvim'
" Initialize plugin system
call plug#end()

""""" Treesitter configuration """"
lua <<EOF
require'nvim-treesitter.configs'.setup {
	-- Install all syntax modules that have maintainers.
	ensure_installed = "maintained",
	-- Enabled TS powered indentation.
	indent = {
	-- too buggy for use just yet :[
	-- enable = true
	},
	highlight = { enable = true },
}
EOF
""""" /Treesitter configuration """"

""""" Git integration configuration """"
lua require('gitsigns').setup()
""""" /Git integration configuration """"

""""" LSP configuration """"
lua <<EOF
-- LSP configuration
-- For language server specifics, see: https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md

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
  buf_set_keymap('n', 'gr', '<Cmd>ua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap("n", "<space>F", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
end


local lsp_installer = require("nvim-lsp-installer")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
	  properties = {
		'documentation',
		'detail',
		'additionalTextEdits',
	  }
	}
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

    -- This setup() function is exactly the same as lspconfig's setup function.
    -- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
    server:setup(config)
end)
EOF
""""" /LSP configuration """"

""""" Completion Configuration """"
lua <<EOF
-- Not entirely sure what this does but compe says it's required.
vim.o.completeopt = "menuone,noselect"
require'compe'.setup {
  enabled = true;
  autocomplete = true;
  debug = false;
  min_length = 1;
  preselect = 'enable';
  throttle_time = 80;
  source_timeout = 200;
  incomplete_delay = 400;
  max_abbr_width = 100;
  max_kind_width = 100;
  max_menu_width = 100;
  documentation = {
    border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
    winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
    max_width = 120,
    min_width = 60,
    max_height = math.floor(vim.o.lines * 0.3),
    min_height = 1,
  };

  source = {
    path = true;
    buffer = true;
    calc = true;
    nvim_lsp = true;
  };
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
    local col = vim.fn.col('.') - 1
    if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
        return true
    else
        return false
    end
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
EOF
inoremap <silent><expr> <C-Space> compe#complete()
inoremap <silent><expr> <CR>      compe#confirm('<CR>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')
inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
""""" /Completion Configuration """"

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

" Persistent undo
" TODO: There's gotta be a better way to handle this at this point.
if exists("+undofile")
" undofile - This allows you to use undos after exiting and restarting
" This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence
  if isdirectory($HOME . '/.config/nvim/undo') == 0
    :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
  endif
  set undodir=./.vim-undo// undodir+=~/.config/nvim/undo// undofile
endif

lua <<EOF
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
