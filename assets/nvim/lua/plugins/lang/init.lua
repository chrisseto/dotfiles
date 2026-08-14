return {
	{
		"nvim-treesitter/nvim-treesitter",
		-- Merging behaviors happen per module. Without this being specified at least once, the last file in this module would "win".
		opts_extend = { "ensure_installed" },
	},
}
