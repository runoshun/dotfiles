local M = {}

local job_id = nil

function run_proxy_script(args)
	local script_path = vim.fn.stdpath("config") .. "/scripts/github-copilot-proxy/main.ts"
	local id = vim.fn.jobstart("deno run -A " .. script_path .. " " .. args, { detach = true })
	print("Copilot Proxy server started")
	return id
end

function M.start()
	if job_id == nil then
		job_id = run_proxy_script("start")
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

function M.gen_aider_settings()
	run_proxy_script("gen aider")
end

return M
