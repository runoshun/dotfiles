local hyper = { "cmd", "ctrl" }
local hyper2 = { "cmd", "ctrl", "shift" }

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

	-- term
	local double_press = require("ctrlDoublePress")
	local termApp = "Rio"
	double_press.timeFrame = 0.5
	double_press.action = function()
		launchRioTerm()
		adjustWindowsOfApp("0,0 " .. gridSize, "Arc", false)
		alacrittyMaximized = true
	end
	hs.hotkey.bind(hyper, "u", toggleRioTermOpacity)

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
		adjustWindowsOfApp("4,0 2x4", termApp)
		-- adjustWindowsOfApp("4,0 2x4", "AlacrittyFloat")
		alacrittyMaximized = false
	end)
	hs.hotkey.bind(hyper, "h", function()
		adjustWindowsOfApp("0,0 3x4", "Arc")
		adjustWindowsOfApp("3,0 3x4", termApp)
		-- adjustWindowsOfApp("3,0 3x4", "AlacrittyFloat")
		alacrittyMaximized = false
	end)
	hs.hotkey.bind(hyper, "r", function()
		adjustWindowsOfApp("0,0 6x4", "Arc")
		adjustWindowsOfApp("0,0 6x4", termApp)
		-- adjustWindowsOfApp("1,1 4x2", "AlacrittyFloat")
		-- hs.application.find("AlacrittyFloat"):hide()
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
		app:mainWindow():maximize()
	elseif app:isFrontmost() and alacrittyMaximized then
		app:hide()
	elseif app:isFrontmost() and not alacrittyMaximized then
		app:mainWindow():maximize()
		app:setFrontmost()
	else
		local active_space = hs.spaces.focusedSpace()
		local alacritty_win = app:mainWindow()
		hs.spaces.moveWindowToSpace(alacritty_win, active_space)
		app:setFrontmost()
		alacritty_win:maximize()
	end
end

local alacrittyFloatTask = nil
local alacrittyFloatPath = "/Applications/AlacrittyFloat.app/Contents/MacOS/alacritty"
local alacrittyFloatSocketPath = "/tmp/alacritty-float.sock"
function ensureAlacrittyFloatTask(kill)
	if kill then
		os.remove(alacrittyFloatSocketPath)
		local app = hs.application.find("AlacrittyFloat", true)
		if app then
			app:kill()
		end
		alacrittyFloatTask = nil
	end

	if alacrittyFloatTask ~= nil and not alacrittyFloatTask:isRunning() then
		alacrittyFloatTask = nil
	end

	if alacrittyFloatTask == nil then
		alacrittyFloatTask = hs.task.new(alacrittyFloatPath, nil, { "--daemon", "--socket", alacrittyFloatSocketPath })
		alacrittyFloatTask:start()
	end
end

function launchAlacrittyFloat(title, cmd, grid)
	ensureAlacrittyFloatTask()

	local appName = "AlacrittyFloat"
	local app = hs.application.find(appName, true)
	local win = app:getWindow(title)
	local launched = false
	local grid = grid or "1,1 4x2"

	if not win then
		local cmd_opt = string.format(" -e /opt/homebrew/bin/bash -l -c '%s'", cmd)
		if cmd == nil then
			cmd_opt = ""
		end

		local exec_cmd = string.format(
			"%s msg -s %s create-window -o window.opacity=0.9 -o 'window.startup_mode=\"Windowed\"' 'window.title=\"%s\"' 'window.decorations=\"Full\"'%s",
			alacrittyFloatPath,
			alacrittyFloatSocketPath,
			title,
			cmd_opt
		)
		os.execute(exec_cmd)
		launched = true
	end

	hs.timer.doAfter(0.0, function()
		local app = hs.application.find(appName, true)
		local win = app:getWindow(title)
		local frontmostWin = hs.window.frontmostWindow()
		local isFrontmost = frontmostWin
			and frontmostWin:application():name() == appName
			and frontmostWin:title() == title

		if (not isFrontmost and win) or launched then
			-- set grid if app is launched
			if launched then
				hs.grid.set(win, grid)
			end
			app:setFrontmost()
			app:unhide()
			win:unminimize()

			-- hide other windows
			for i, win in ipairs(app:allWindows()) do
				if win:title() ~= title then
					win:minimize()
				end
			end
		else
			app:hide()
		end
	end)
end

function toggleAlacrittyOpacity()
	local appName = "Alacritty"
	local app = hs.application.find(appName, true)
	local exec = "/Applications/Alacritty.app/Contents/MacOS/alacritty"
	if app.isFrontmost(app) then
		if alacrittyOpacity == 1.0 then
			hs.execute(exec .. " msg config window.opacity=0.8", true)
			alacrittyOpacity = 0.8
		elseif alacrittyOpacity == 0.8 then
			hs.execute(exec .. " msg config window.opacity=0.6", true)
			alacrittyOpacity = 0.6
		else
			hs.execute(exec .. " msg config window.opacity=1.0", true)
			alacrittyOpacity = 1.0
		end
	end
end

-- Rio
function launchRioTerm()
	local appName = "Rio"
	local app = hs.application.find(appName, true)

	if app == nil then
		hs.application.launchOrFocus(appName)
		local app = hs.application.get(appName)
		app:mainWindow():maximize()
	elseif app:isFrontmost() and alacrittyMaximized then
		app:hide()
	elseif app:isFrontmost() and not alacrittyMaximized then
		app:mainWindow():maximize()
		app:setFrontmost()
	else
		local active_space = hs.spaces.focusedSpace()
		local alacritty_win = app:mainWindow()
		hs.spaces.moveWindowToSpace(alacritty_win, active_space)
		app:setFrontmost()
		alacritty_win:maximize()
	end
end

function toggleRioTermOpacity()
	config_file_name = string.format("%s/.config/rio/config.toml", os.getenv("HOME"))

	opaque = "opacity = 1.0"
	transparent = "opacity = 0.75"

	local file = io.open(config_file_name)

	local content = file:read("*a")
	file:close()

	if string.match(content, opaque) then
		content = string.gsub(content, opaque, transparent)
	else
		content = string.gsub(content, transparent, opaque)
	end

	local fileedited = io.open(config_file_name, "w")
	fileedited:write(content)
	fileedited:close()
end

setup()
