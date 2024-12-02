local function newMemo()
	local title = vim.fn.input("Title: ")
	if title == "" then
		return
	end

	local date = os.date("%Y-%m-%d")
	local dir = vim.fn.expand("~/.config/memo/_posts")

	local fname = dir .. "/" .. date .. "-" .. title .. ".md"
	if vim.fn.filereadable(fname) == 1 then
		vim.cmd("e " .. fname)
	else
		vim.cmd("enew")
		vim.api.nvim_buf_set_name(0, dir .. "/" .. date .. "-" .. title .. ".md")
		vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split("# " .. title, "\n"))
	end
end

local function todayMemo()
	local fname = vim.fn.system("memo today -vim")
	vim.cmd("e " .. fname)
end

local serverJobId = nil
local function restartServer()
	if serverJobId ~= nil then
		vim.fn.jobstop(serverJobId)
		serverJobId = nil
	end

	serverJobId = vim.fn.jobstart("memo serve")
	print("Copilot Proxy server started")
end

return {
	{
		-- load from .config/nvim/lua/telescope-memo.nvim
		dir = vim.fn.expand("~/.config/nvim/lua/telescope-memo.nvim"),
		keys = {
			{ "<leader>ml", "<cmd>Telescope memo list<cr>",      desc = "Find memos" },
			{ "<leader>ms", "<cmd>Telescope memo live_grep<cr>", desc = "Grep memos" },
			{ "<leader>mt", "<cmd>Telescope memo list_todo<cr>", desc = "Grep todo" },
			{ "<leader>mP", "<cmd>!memo push<cr>",               desc = "Push memos to Git" },
			{ "<leader>mp", "<cmd>!memo pull<cr>",               desc = "Pull memos from Git" },
			{ "<leader>mn", newMemo,                             desc = "New memo" },
			{ "<leader>mm", todayMemo,                           desc = "Today memo" },
			{ "<leader>mS", restartServer,                       desc = "Start memo server" },
		},
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require("telescope").load_extension("memo")
		end,
	},
}
