local module = {}

module.toggle_alacritty_opacity = function()
	local alacritty_file_name = string.format("%s/.config/alacritty/alacritty.toml", os.getenv("HOME"))

	local opaque = "opacity = 1.0"
	local transparent1 = "opacity = 0.80"
	local transparent2 = "opacity = 0.60"

	local file = io.open(alacritty_file_name)

	local content = file:read("*a")
	file:close()

	if string.match(content, opaque) then
		content = string.gsub(content, opaque, transparent1)
	elseif string.match(content, transparent1) then
		content = string.gsub(content, transparent1, transparent2)
	else
		content = string.gsub(content, transparent2, opaque)
	end

	local fileedited = io.open(alacritty_file_name, "w")
	fileedited:write(content)
	fileedited:close()
end

module.launch_alacritty = function()
	local appName = "Alacritty"
	local app = hs.application.find(appName, true)

	if app == nil then
		hs.application.launchOrFocus(appName)
	elseif app:isFrontmost() then
		app:hide()
	else
		local active_space = hs.spaces.focusedSpace()
		local alacritty_win = app:focusedWindow()
		hs.spaces.moveWindowToSpace(alacritty_win, active_space)
		app:setFrontmost()
	end
end

module.launch_wezterm = function()
	local appName = "WezTerm"
	local app = hs.application.find(appName, true)

	if app == nil then
		hs.application.launchOrFocus(appName)
	elseif app:isFrontmost() then
		app:hide()
	else
		local active_space = hs.spaces.focusedSpace()
		local alacritty_win = app:focusedWindow()
		hs.spaces.moveWindowToSpace(alacritty_win, active_space)
		app:setFrontmost()
	end
end

return module
