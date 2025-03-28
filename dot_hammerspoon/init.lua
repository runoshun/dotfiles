local hyper = { "cmd", "ctrl" }
local hyperShift = { "cmd", "ctrl", "shift" }

hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("ReloadConfiguration", {
	start = true,
	config = { watch_paths = { hs.configdir } },
})
spoon.SpoonInstall:andUse("ClipboardTool", {
	start = true,
	config = { show_copied_alert = false, show_in_menubar = false },
	hotkeys = { toggle_clipboard = { hyper, "v" } },
})
spoon.SpoonInstall:andUse("Seal", {
	start = true,
	hotkeys = { show = { { "ctrl" }, "return" } },
	fn = function(s)
		s:loadPlugins({ "apps", "calc", "screencapture", "useractions" })
		s:refreshAllCommands()
	end,
})
spoon.SpoonInstall:andUse("PaperWM", {
	start = true,
	config = { screen_margin = 16, window_gap = 2 },
	fn = function(s)
		s.window_ratios = { 0.5, 0.98 }
		s:bindHotkeys({
			-- switch to a new focused window in tiled grid
			focus_left = { hyper, "h" },
			focus_right = { hyper, "l" },

			-- move windows around in tiled grid
			swap_left = { hyperShift, "h" },
			swap_right = { hyperShift, "l" },

			-- position and resize focused window
			center_window = { hyper, "c" },
			cycle_width = { hyper, "m" },

			-- move the focused window into / out of the tiling layer
			toggle_floating = { hyper, "f" },
		})
	end,
})

hs.window.animationDuration = 0.02

local shell = require("shell_utils")
local App = require("app_utils")
local term = App:new("Ghostty")

local function bindTmuxSwitches()
	local sshPath = shell.which("ssh")

	for i = 1, 9 do
		hs.hotkey.bind({ "cmd" }, tostring(i), function()
			shell.execute_async(sshPath, { "default", "tmux switch-client -t " .. tostring(i) .. "-" }, function()
				term:activate()
			end)
		end)
	end
end

local function init()
	local double_press = require("ctrlDoublePress")
	double_press.timeFrame = 0.5
	double_press.action = function()
		term:activate()
	end

	bindTmuxSwitches()
end

init()
