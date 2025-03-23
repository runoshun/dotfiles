-- window_manager.lua
local windowManager = {}

-- Default grid configuration and margins (can be updated externally)
windowManager.config = {
  grid = "20x10",
  margins = { w = 0, h = 0 },
  steps = { 0.5, 0.6, 0.4 }
}

-- Initialize hs.grid with default config
hs.grid.setGrid(windowManager.config.grid)
hs.grid.setMargins(windowManager.config.margins)

-- State table to track last action for cycling
windowManager.lastAction = {
  winID = nil,
  action = nil,
  cycleIndex = 0,
  timestamp = 0
}

-- Function to update grid config externally
function windowManager.setGrid(grid, margins)
  windowManager.config.grid = grid
  windowManager.config.margins = margins or { w = 0, h = 0 }
  hs.grid.setGrid(grid)
  hs.grid.setMargins(windowManager.config.margins)
end

-- Helper: update cycle based on action repetition
local function updateCycle(action)
  local win = hs.window.focusedWindow()
  if not win then return 1 end

  local id = win:id()
  local now = hs.timer.secondsSinceEpoch()

  if windowManager.lastAction.winID == id and windowManager.lastAction.action == action and
      (now - windowManager.lastAction.timestamp < 1) then
    windowManager.lastAction.cycleIndex = (windowManager.lastAction.cycleIndex % 3) + 1
  else
    windowManager.lastAction.cycleIndex = 1
  end

  windowManager.lastAction.winID = id
  windowManager.lastAction.action = action
  windowManager.lastAction.timestamp = now

  return windowManager.lastAction.cycleIndex
end

-- Move active window to left side with cycling widths.
function windowManager.moveLeft()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screen = win:screen()
  local grid = hs.grid.getGrid(screen)
  local cycle = updateCycle("left")
  local gw = grid.w

  local rect = {}
  rect.y = 0
  rect.h = grid.h
  rect.x = 0

  rect.w = math.floor(gw * windowManager.config.steps[cycle])
  hs.grid.set(win, rect, screen)
end

-- Move active window to right side with cycling widths.
function windowManager.moveRight()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screen = win:screen()
  local grid = hs.grid.getGrid(screen)
  local cycle = updateCycle("right")
  local gw = grid.w

  local rect = {}
  rect.y = 0
  rect.h = grid.h

  rect.w = math.floor(gw * windowManager.config.steps[cycle])
  rect.x = gw - rect.w
  hs.grid.set(win, rect, screen)
end

-- Move active window to center with cycling widths.
function windowManager.moveCenter()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screen = win:screen()
  local grid = hs.grid.getGrid(screen)
  local cycle = updateCycle("center")
  local gw = grid.w

  local rect = {}
  rect.y = 0
  rect.h = grid.h

  rect.w = math.floor(gw * windowManager.config.steps[cycle])
  rect.x = math.floor((gw - rect.w) / 2)
  hs.grid.set(win, rect, screen)
end

-- Additional utility: maximize the window to occupy the full grid.
function windowManager.maximize()
  local win = hs.window.focusedWindow()
  if not win then return end
  hs.grid.maximizeWindow(win)
end

return windowManager
