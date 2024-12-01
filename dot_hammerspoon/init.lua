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
