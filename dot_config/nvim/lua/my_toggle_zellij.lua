-- ZellijTerminalクラスの定義
local ZellijTerminal = {}
ZellijTerminal.__index = ZellijTerminal

-- ZellijTerminalクラスのコンストラクタ
function ZellijTerminal:new(height, position, command, exit)
	local obj = setmetatable({}, self)
	obj.height = height or 10
	obj.position = position or "bottom"
	obj.command = command or nil
	obj.pane_id = nil
	obj.exit = exit or nil
	return obj
end

-- Zellijペインを開くメソッド
function ZellijTerminal:open(...)
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

	local zellij_command = "zellij action new-pane --"
	if self.position == "bottom" then
		zellij_command = zellij_command .. "bottom"
	elseif self.position == "right" then
		zellij_command = zellij_command .. "right"
	end

	if self.height then
		zellij_command = zellij_command .. " --size " .. self.height
	end

	if cmd then -- cmdがnilでない場合のみ実行
		zellij_command = zellij_command .. " -- " .. cmd
	end

	vim.fn.system(zellij_command)
	self.pane_id = vim.fn.system("zellij action list-panes | grep -oP '(?<=:).*$' | head -n 1")
end

-- Zellijペインの表示非表示を切り替えるメソッド
function ZellijTerminal:toggle(...)
	if self.pane_id and vim.fn.system("zellij action list-panes | grep " .. self.pane_id) ~= "" then
		vim.fn.system("zellij action toggle-pane-embed-or-floating")
	else
		self:open(...)
	end
end

return ZellijTerminal
