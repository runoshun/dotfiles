local double_press = require("ctrlDoublePress")

local launchAlacritty = function()
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

double_press.timeFrame = 0.5
double_press.action = launchAlacritty


hs.hotkey.bind({ "cmd" }, "U", function()
  alacritty_file_name = string.format("%s/.config/alacritty/alacritty.toml", os.getenv("HOME"))

  opaque = "opacity = 1.0"
  transparent = "opacity = 0.8"

  local file = io.open(alacritty_file_name)

  local content = file:read "*a"
  file:close()

  if string.match(content, opaque) then
    content = string.gsub(content, opaque, transparent)
  else
    content = string.gsub(content, transparent, opaque)
  end

  local fileedited = io.open(alacritty_file_name, "w")
  fileedited:write(content)
  fileedited:close()
end)
