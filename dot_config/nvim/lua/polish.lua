-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here


vim.keymap.set('n', '<Leader>k', function()
    local key = vim.fn.getcharstr()
    local byte = string.byte(key)
    local key_name = vim.fn.keytrans(key)

    print("Raw input: " .. vim.inspect(key))
    print("Byte value: " .. byte)
    print("Key name: " .. key_name)

    -- 修飾キーの検出
    local mods = ""
    if vim.fn.match(key, "\\C^\\(<C-\\)") > -1 then mods = mods .. "Ctrl+" end
    if vim.fn.match(key, "\\C^\\(<M-\\|<A-\\)") > -1 then mods = mods .. "Alt+" end
    if vim.fn.match(key, "\\C^\\(<S-\\)") > -1 then mods = mods .. "Shift+" end

    if mods ~= "" then
      print("Modifiers: " .. mods:sub(1, -2)) -- 最後の "+" を削除
    end
  end,
  { noremap = true, silent = true })


if os.getenv("SSH_CONNECTION") ~= nil then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
      ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
    },
    paste = {
      ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
      ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
    },
  }
end

-- aider
local Terminal = require('toggleterm.terminal').Terminal
local aider = Terminal:new({ cmd = "aider", hidden = true, direction = "vertical" })
function _aider_toggle()
  aider:toggle(80)
end

-- vim.api.nvim_create_autocmd("TermClose", {
--   callback = function()
--     vim.cmd("close")
--   end
-- })
