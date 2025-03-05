hs.hotkey.bind({ "ctrl", "cmd" }, "r", function()
	hs.execute("chezmoi apply", true)
	hs.reload()
	print("Hammerspoon reloaded")
end)

-- switcher
local switcher = require("switcher")
switcher.bindNext("alt", "tab")
switcher.bindPrevious("alt-shift", "tab")

-- window management
require("window-layouts")
double_press.timeFrame = 0.5
double_press.action = teminal.launch_wezterm
-- double_press.action = teminal.launch_alacritty
--hs.hotkey.bind({ "cmd" }, "U", teminal.toggle_opacity)

-- -- launcher
-- local launcher = require("launcher")
-- -- Command + Spaceでランチャーを表示 (デフォルトのSpotlightショートカットを上書きします)
-- hs.hotkey.bind({ "cmd" }, "space", showLauncher)
