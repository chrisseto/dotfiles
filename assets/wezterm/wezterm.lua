-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.font = wezterm.font "Fira Code"
config.color_scheme = 'Everforest Dark (Gogh)'
config.hide_tab_bar_if_only_one_tab = true -- Save space if only one tab.
config.window_decorations = "RESIZE" -- Disables the title bar but preserves window operations.
config.audible_bell = "Disabled" -- No bells.

config.leader = { key = ' ', mods = 'CTRL', timeout_milliseconds = 1000 }
config.keys = {
	{
		key = '"',
		mods = 'LEADER|SHIFT',
		action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
	},
	{
		key = '%',
		mods = 'LEADER|SHIFT',
		action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
	},
	{
		key = 'z',
		mods = 'LEADER',
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = 'j',
		mods = 'CTRL',
		action = wezterm.action.ActivatePaneDirection 'Down',
	},
	{
		key = 'k',
		mods = 'CTRL',
		action = wezterm.action.ActivatePaneDirection 'Up',
	},
	{
		key = 'l',
		mods = 'CTRL',
		action = wezterm.action.ActivatePaneDirection 'Right',
	},
	{
		key = 'h',
		mods = 'CTRL',
		action = wezterm.action.ActivatePaneDirection 'Left',
	},
	{
		key = 'RightArrow',
		mods = 'SUPER',
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = 'LeftArrow',
		mods = 'SUPER',
		action = wezterm.action.ActivateTabRelative(-1),
	},
}

-- Smart splits integration to allow navigating vim panes and wezterm panes.
-- See https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#multiplexer-integrations
local smart_splits = wezterm.plugin.require('https://github.com/mrjones2014/smart-splits.nvim')

-- Using the defaults of smart_splits. h, j, k, l for up, down, left, right.
smart_splits.apply_to_config(config)

-- and finally, return the configuration to wezterm
return config
