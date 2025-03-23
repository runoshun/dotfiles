local App = {}
App.__index = App

function App:new(appName)
  local instance = setmetatable({}, App)
  instance.appName = appName
  return instance
end

function App:getApp()
  return hs.application.find(self.appName, true)
end

function App:activate()
  self:toggle(true)
end

function App:toggle(no_hide_arg)
  local app = self:getApp()
  local no_hide = no_hide_arg == nil and false or no_hide_arg

  if app == nil then
    hs.application.launchOrFocus(self.appName)
  elseif app:isFrontmost() then
    if not no_hide then
      app:hide()
    end
  else
    local active_space = hs.spaces.focusedSpace()
    local app_win = app:focusedWindow()
    hs.spaces.moveWindowToSpace(app_win, active_space)
    app:setFrontmost()
  end
end

return App
