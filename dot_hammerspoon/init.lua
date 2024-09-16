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
