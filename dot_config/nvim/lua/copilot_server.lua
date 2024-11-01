local M = {}

local job_id = nil

function M.start()
	if job_id == nil then
		local script_path = vim.fn.stdpath("config") .. "/scripts/github-copilot-proxy/main.ts"
		job_id = vim.fn.jobstart("deno run -A " .. script_path, { detach = true })
		print("Copilot Proxy server started")
	else
		print("Copilot Proxy server is already running")
	end
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
