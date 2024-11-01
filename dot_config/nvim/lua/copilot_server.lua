
local M = {}

local job_id = nil

function M.start()
  if job_id == nil then
    job_id = vim.fn.jobstart('deno run -A dot_config/nvim/scripts/github-copilot-proxy/main.ts', { detach = true })
    print("Copilot Proxy server started")
  else
    print("Copilot Proxy server is already running")
  }
end

function M.stop()
  if job_id ~= nil then
    vim.fn.jobstop(job_id)
    job_id = nil
    print("Copilot Proxy server stopped")
  else
    print("Copilot Proxy server is not running")
  end
end

function M.restart()
  M.stop()
  M.start()
end

return M
