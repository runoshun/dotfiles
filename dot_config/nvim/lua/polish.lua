-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- クリップボードの設定
local function paste()
	return {
		vim.fn.split(vim.fn.getreg(""), "\n"),
		vim.fn.getregtype(""),
	}
end

vim.o.clipboard = "unnamedplus"

if os.getenv("SSH_CONNECTION") ~= nil then
	vim.g.clipboard = {
		name = "OSC 52",
		copy = {
			["+"] = require("vim.ui.clipboard.osc52").copy("+"),
			["*"] = require("vim.ui.clipboard.osc52").copy("*"),
		},
		paste = {
			["+"] = paste,
			["*"] = paste,
		},
	}
end

-- キーマップリーダー
vim.keymap.set(
	"n",
	"<Leader>k",
	require("my_keymap_debugger"),
	{ noremap = true, silent = true, desc = "Keymap Debugger" }
)

-- キーマップ
local MyTerminal = require("my_toggle_terminal")
_G._my_rightbelow_terminal = MyTerminal:new(15, "belowright")
_G._my_aider_terminal = MyTerminal:new(72, "vertical belowright", function(files, watch)
	local file_args = {}
	local bufnrs
	if files == "all" then
		bufnrs = vim.api.nvim_list_bufs()
	else
		bufnrs = { vim.api.nvim_get_current_buf() }
	end

	print(vim.inspect(bufnrs))
	local cwd = vim.fn.getcwd()
	for _, bufnr in ipairs(bufnrs) do
		if vim.api.nvim_buf_is_loaded(bufnr) then
			local bufpath = vim.api.nvim_buf_get_name(bufnr)
			local file_exsit = vim.fn.filereadable(bufpath)
			if file_exsit == 1 and vim.startswith(bufpath, cwd) then
				table.insert(file_args, "--file")
				table.insert(file_args, '"' .. bufpath .. '"')
			end
		end
	end

	return "aider --env-file ~/.aider.env " .. table.concat(file_args, " ")
end, true)

local copilot_server = require("copilot_server")
vim.api.nvim_create_user_command("StartCopilotProxy", copilot_server.start, {})
vim.api.nvim_create_user_command("StopCopilotProxy", copilot_server.stop, {})
vim.api.nvim_create_user_command("RestartCopilotProxy", copilot_server.restart, {})
vim.api.nvim_create_user_command("GenerateAiderSettings", copilot_server.gen_aider_settings, {})

vim.keymap.set(
	{ "n", "t" },
	"<F12>",
	"<cmd>lua _G._my_rightbelow_terminal:toggle()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Right Below Terminal" }
)
vim.keymap.set(
	"n",
	"<leader>ai",
	"<cmd>lua _G._my_aider_terminal:toggle()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Aider Terminal" }
)
vim.keymap.set(
	"n",
	"<leader>aI",
	"<cmd>lua _G._my_aider_terminal:toggle('all')<CR>",
	{ noremap = true, silent = true, desc = "Toggle Aider Terminal" }
)
vim.keymap.set(
	"n",
	"<leader>aa",
	"<cmd>CopilotChatToggle<CR>",
	{ noremap = true, silent = true, desc = "Toggle Copilot Chat" }
)
vim.keymap.set(
	"n",
	"<leader>aP",
	"<cmd>RestartCopilotProxy<CR>",
	{ noremap = true, silent = true, desc = "Restart Copilot Proxy" }
)
