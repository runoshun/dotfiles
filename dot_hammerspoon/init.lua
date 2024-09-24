local switcher = hs.window.switcher.new()
switcher.ui.showSelectedThumbnail = false
switcher.ui.textSize = 14
switcher.ui.backgroundColor = { 0, 0, 0, 0.8 }
switcher.ui.highlightColor = { 0.3, 0.3, 0.3, 0.8 }
hs.hotkey.bind(
	"alt",
	"tab",
	function()
		switcher:next()
	end,
	nil,
	function()
		switcher:next()
	end
)
hs.hotkey.bind(
	"alt-shift",
	"tab",
	function()
		switcher:previous()
	end,
	nil,
	function()
		switcher:previous()
	end
)

-- alacritty
local double_press = require("ctrlDoublePress")
local teminal = require("terminalUtils")

double_press.timeFrame = 0.5
double_press.action = teminal.launch_alacritty
hs.hotkey.bind({ "cmd" }, "U", teminal.toggle_opacity)

-- -- launcher
-- local launcher = require("launcher")
-- -- Command + Spaceでランチャーを表示 (デフォルトのSpotlightショートカットを上書きします)
-- hs.hotkey.bind({ "cmd" }, "space", showLauncher)
