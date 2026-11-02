-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- config.font = wezterm.font "Fira Code"
config.color_scheme = "Everforest Dark (Gogh)"
config.hide_tab_bar_if_only_one_tab = true -- Save space if only one tab.
config.window_decorations = "RESIZE" -- Disables the title bar but preserves window operations.
config.audible_bell = "Disabled" -- No bells.

-- All ssh domains will be connecting to unix systems.
-- Inform wezterm of this so it can be a bit fancy.
-- config.ssh_domains = wezterm.default_ssh_domains()
-- for _, dom in ipairs(config.ssh_domains) do
-- 	dom.assume_shell = "Posix"
-- end

config.leader = { key = " ", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{
		key = '"',
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "%",
		mods = "LEADER|SHIFT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "[",
		mods = "LEADER",
		action = wezterm.action.ActivateCopyMode,
	},
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
	{
		key = "j",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "l",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "h",
		mods = "CTRL",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "RightArrow",
		mods = "SUPER",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		key = "LeftArrow",
		mods = "SUPER",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	-- For claude code.
  {key="Enter", mods="SHIFT", action=wezterm.action{SendString="\x1b\r"}},
}

-- Smart splits integration to allow navigating vim panes and wezterm panes.
-- See https://github.com/mrjones2014/smart-splits.nvim?tab=readme-ov-file#multiplexer-integrations
local smart_splits = wezterm.plugin.require("https://github.com/mrjones2014/smart-splits.nvim")

-- Using the defaults of smart_splits. h, j, k, l for up, down, left, right.
smart_splits.apply_to_config(config)

-- Tint tabs whose active pane lives in an ssh domain with a color hashed from
-- the host, drawn from the scheme's accent colors.
local scheme = wezterm.color.get_builtin_schemes()[config.color_scheme]
local tab_palette = {}
for i = 2, 7 do -- red through cyan
	table.insert(tab_palette, scheme.ansi[i])
	table.insert(tab_palette, scheme.brights[i])
end

local function host_color(host)
	local h = 5381
	for i = 1, #host do
		h = (h * 33 + host:byte(i)) % 4294967296
	end
	return wezterm.color.parse(tab_palette[h % #tab_palette + 1])
end

wezterm.on("format-tab-title", function(tab)
	local title = tab.tab_title ~= "" and tab.tab_title or tab.active_pane.title
	local host = tab.active_pane.domain_name:match("^SSH%u*:(.+)$")
	if not host then
		return title
	end
	local c = host_color(host)
	return {
		{ Background = { Color = tab.is_active and c or c:darken(0.4) } },
		{ Foreground = { Color = scheme.background } },
		{ Text = " [" .. host .. "] " .. title .. " " },
	}
end)

-- and finally, return the configuration to wezterm
return config
