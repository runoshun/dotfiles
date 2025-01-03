-- ZellijTerminalクラスの定義
local ZellijTerminal = {}
ZellijTerminal.__index = ZellijTerminal

-- ZellijTerminalクラスのコンストラクタ
function ZellijTerminal:new(size, position, command, exit)
	local obj = setmetatable({}, self)
	obj.size = size or 10
	obj.position = position or "bottom"
	obj.command = command or nil
	obj.exit = exit or nil
	return obj
end

-- Zellijペインを開くメソッド
function ZellijTerminal:open(...)
	local cmd
	if self.command then
		if type(self.command) == "function" then
			cmd = self.command(...)
		else
			cmd = self.command
		end
	end

	local zellij_command = "zellij action new-pane "
	if self.position == "bottom" then
		zellij_command = zellij_command .. "-d down"
	elseif self.position == "right" then
		zellij_command = zellij_command .. "-d right"
	end

	if cmd then -- cmdがnilでない場合のみ実行
		zellij_command = zellij_command .. " -- " .. cmd
	end

	vim.fn.system(zellij_command)
end

return ZellijTerminal
