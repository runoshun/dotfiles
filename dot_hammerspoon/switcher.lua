local switcher = hs.window.switcher.new()
switcher.ui.showSelectedThumbnail = false
switcher.ui.textSize = 14
switcher.ui.backgroundColor = { 0, 0, 0, 0.8 }
switcher.ui.highlightColor = { 0.3, 0.3, 0.3, 0.8 }

local function bindNext(mod, key)
	hs.hotkey.bind(
		mod,
		key,
		function()
			switcher:next()
		end,
		nil,
		function()
			switcher:next()
		end
	)
end

local function bindPrevious(mod, key)
	hs.hotkey.bind(
		mod,
		key,
		function()
			switcher:previous()
		end,
		nil,
		function()
			switcher:previous()
		end
	)
end

return {
	bindNext = bindNext,
	bindPrevious = bindPrevious,
}
