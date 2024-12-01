local hyper = { "cmd", "ctrl" }

-- flags
local alacrittyOpacity = 1.0
local alacrittyMaximized = false

function setup()
	-- Grid
	local gridSize = "6x4"
	hs.grid.setMargins(hs.geometry.size(0, 0))
	hs.grid.setGrid(gridSize)
	hs.window.animationDuration = 0.00

	hs.hotkey.bind(hyper, "g", function()
		hs.grid.show()
	end)

	-- alacritty
	local double_press = require("ctrlDoublePress")
	double_press.timeFrame = 0.5
	double_press.action = function()
		launchAlacritty()
		adjustWindowsOfApp("0,0 " .. gridSize, "Arc", false)
		nextTerminalSize = 2
		alacrittyMaximized = true
	end
	hs.hotkey.bind(hyper, "u", toggleAlacrittyOpacity)

	-- Application mappings
	local appMaps = {
		b = "Arc",
		s = "Slack",
	}

	for appKey, appName in pairs(appMaps) do
		hs.hotkey.bind(hyper, appKey, function()
			hs.application.launchOrFocus(appName)
			hs.grid.set(hs.window.focusedWindow(), "0,0 " .. gridSize)
		end)
	end

	-- Layouts
	-- browser and terminal
	hs.hotkey.bind(hyper, "l", function()
		adjustWindowsOfApp("0,0 4x4", "Arc")
		adjustWindowsOfApp("4,0 2x4", "Alacritty")
		alacrittyMaximized = false
	end)
	hs.hotkey.bind(hyper, "h", function()
		adjustWindowsOfApp("0,0 3x4", "Arc")
		adjustWindowsOfApp("3,0 3x4", "Alacritty")
		alacrittyMaximized = false
	end)
	hs.hotkey.bind(hyper, "m", function()
		adjustWindowsOfApp("0,0 6x4", "Arc")
		adjustWindowsOfApp("0,0 6x4", "Alacritty")
		alacrittyMaximized = true
	end)
end

function adjustWindowsOfApp(gridSettings, appName, focus)
	focus = focus == nil and true or focus
	local app = hs.application.get(appName)
	if not app then
		hs.application.launchOrFocus(appName)
		app = hs.application.get(appName)
	end

	local wins
	if app then
		if focus then
			app:setFrontmost()
		end
		wins = app:allWindows()
	end

	if wins then
		for i, win in ipairs(wins) do
			hs.grid.set(win, gridSettings)
		end
	end
end

-- Alacritty
function launchAlacritty()
	local appName = "Alacritty"
	local app = hs.application.find(appName, true)

	if app == nil then
		hs.application.launchOrFocus(appName)
		local app = hs.application.get(appName)
		app:getWindow("Main"):maximize()
	elseif app:isFrontmost() and alacrittyMaximized then
		app:hide()
	elseif app:isFrontmost() and not alacrittyMaximized then
		app:getWindow("Main"):maximize()
		app:setFrontmost()
	else
		local active_space = hs.spaces.focusedSpace()
		local alacritty_win = app:getWindow("Main")
		hs.spaces.moveWindowToSpace(alacritty_win, active_space)
		app:setFrontmost()
		alacritty_win:maximize()
	end
end

function toggleAlacrittyOpacity()
	local appName = "alacritty"
	local app = hs.application.find(appName)
	if app.isFrontmost(app) then
		if alacrittyOpacity == 1.0 then
			hs.execute("alacritty msg config window.opacity=0.8", true)
			alacrittyOpacity = 0.8
		elseif alacrittyOpacity == 0.8 then
			hs.execute("alacritty msg config window.opacity=0.6", true)
			alacrittyOpacity = 0.6
		else
			hs.execute("alacritty msg config window.opacity=1.0", true)
			alacrittyOpacity = 1.0
		end
	end
end

setup()
