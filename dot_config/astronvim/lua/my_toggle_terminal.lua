-- Terminalクラスの定義
local Terminal = {}
Terminal.__index = Terminal

-- Terminalクラスのコンストラクタ
function Terminal:new(height, position, command, exit)
	local obj = setmetatable({}, self)
	obj.height = height or 10
	obj.position = position or "botright"
	obj.command = command or nil
	obj.bufnr = nil
	obj.exit = exit or nil
	return obj
end

-- ターミナルウィンドウを開くメソッド
function Terminal:open(...)
	-- 実行するコマンドを最初に取得
	local cmd
	if self.command then
		if type(self.command) == "function" then
			-- 関数の場合は実行結果を使用
			cmd = self.command(...)
		else
			-- 文字列の場合はそのまま使用
			cmd = self.command
		end
	end

	vim.api.nvim_command(self.position .. " " .. self.height .. "split | terminal")
	self.bufnr = vim.api.nvim_get_current_buf()
	-- ターミナルバッファをバッファ一覧から隠す
	vim.api.nvim_set_option_value("buflisted", false, { buf = self.bufnr })
	-- ターミナルバッファが終了したときにウィンドウを閉じる自動コマンドを設定
	vim.api.nvim_create_autocmd("TermClose", {
		buffer = self.bufnr,
		callback = function()
			local winid = vim.fn.bufwinid(self.bufnr)
			if winid ~= -1 then
				vim.api.nvim_win_close(winid, true)
			end
			self.bufnr = nil
		end,
	})
	-- ターミナルを開いたときにインサートモードに入る
	vim.api.nvim_command("startinsert")

	if cmd then -- cmdがnilでない場合のみ実行
		if self.exit then
			cmd = cmd .. "; exit"
		end
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd .. "\n", true, false, true), "n", true)
	end
end

-- ターミナルウィンドウの表示非表示を切り替えるメソッド
function Terminal:toggle(...)
	if self.bufnr and vim.api.nvim_buf_is_valid(self.bufnr) then
		local winid = vim.fn.bufwinid(self.bufnr)
		if winid ~= -1 then
			vim.api.nvim_win_hide(winid)
		else
			vim.api.nvim_command(self.position .. " " .. self.height .. "split | b" .. self.bufnr)
			vim.api.nvim_command("startinsert")
		end
	else
		self:open(...)
	end
end

return Terminal
