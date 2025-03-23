local M = {}

M.execute_async = function(command, args, callback)
  local task = hs.task.new(command, function(task, exitCode, stdOut)
    callback(stdOut)
  end, args)
  task:start()
end

M.which = function(executable, silent)
  local silent_ = silent == nil and false or silent
  local path = hs.execute("which " .. executable, true):gsub("\n", "")
  if not silent_ and path == "" then
    hs.alert.show(executable .. " not found!")
  end
  return path
end

return M
