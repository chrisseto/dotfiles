hs.grid.setGrid('2x2')
hs.grid.setMargins('0x0')

hs.hotkey.bind({"ctrl"}, "`", function()
  local app = hs.application.get("Alacritty")
  local currentSpace = hs.spaces.focusedSpace()

  -- If Alacritty hasn't been launched yet, start it up.
  if not app then
    hs.application.launchOrFocus("Alacritty")
  elseif app:isFrontmost() then
    app:hide()
  else
	  -- First move the main window to the current space
	  hs.spaces.moveWindowToSpace(app:mainWindow(), currentSpace)
	  -- Activate the app
	  app:activate()
	  -- Raise the main window and position correctly
	  app:mainWindow():raise()
  end
end)

hs.hotkey.bind({"ctrl", "alt"}, "up", function()
  hs.grid.set(hs.window.focusedWindow(), '0,0, 2x2')
end)

hs.hotkey.bind({"ctrl", "alt"}, "Left", function()
  hs.grid.set(hs.window.focusedWindow(), '0,0, 1x2')
end)

hs.hotkey.bind({"ctrl", "alt"}, "Right", function()
  hs.grid.set(hs.window.focusedWindow(), '1,0, 1x2')
end)
