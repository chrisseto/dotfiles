return {
	{'gpanders/nvim-parinfer'},
	{
		'Olical/conjure',
		lazy = true,
		-- janet -e "(import spork/netrepl) (netrepl/server)"
		ft = { "janet" },
		config = function(_, opts)
			require("conjure.main").main()
			require("conjure.mapping")["on-filetype"]()
		end,
		init = function()
			-- Set configuration options here
			-- vim.g["conjure#debug"] = true
		end,
	},
}
