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

local ZellijTerminal = require("zellij_new_pane")
_G._my_aider_terminal = ZellijTerminal:new(72, "vertical belowright", function(files, watch)
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
vim.api.nvim_create_user_command("RestartCopilotProxy", copilot_server.restart, {})

vim.keymap.set(
	{ "n", "t" },
	"<F12>",
	"<cmd>lua _G._my_rightbelow_terminal:toggle()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Right Below Terminal" }
)
vim.keymap.set(
	"n",
	"<leader>ai",
	"<cmd>lua _G._my_aider_terminal:open()<CR>",
	{ noremap = true, silent = true, desc = "Toggle Aider Terminal" }
)
vim.keymap.set(
	"n",
	"<leader>aI",
	"<cmd>lua _G._my_aider_terminal:open('all')<CR>",
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

-- workarounds for nvim-lspconfig

-- -- 現在のファイルから上位ディレクトリをたどってファイルを探す関数
-- local function find_file_upwards(filename)
-- 	-- 現在のディレクトリを取得
-- 	local current_dir = vim.fn.expand("%:p:h")
--
-- 	-- ディレクトリを上にたどる
-- 	while current_dir ~= "/" do -- Windowsの場合は 'C:\\' などのドライブルートも考慮する必要があります
-- 		local file_path = current_dir .. "/" .. filename
-- 		local f = io.open(file_path, "r")
-- 		if f ~= nil then
-- 			io.close(f)
-- 			return true
-- 		end
-- 		-- 親ディレクトリに移動
-- 		current_dir = vim.fn.fnamemodify(current_dir, ":h")
-- 	end
-- 	return false
-- end
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
-- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
-- require("lspconfig").spyglassmc_language_server.setup({
-- 	filetypes = { "mcfunction", "json" },
-- 	capabilities = capabilities,
-- 	on_attach = function(client, bufnr)
-- 		if not find_file_upwards("pack.mcmeta") then
-- 			vim.lsp.stop_client(client.id)
-- 		end
-- 	end,
-- })

-- mcfunction
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "*.mcfunction",
	callback = function()
		vim.bo.filetype = "mcfunction"
	end,
})
