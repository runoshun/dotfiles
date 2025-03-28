require "nvchad.options"

local o = vim.o
o.cursorlineopt = "both"

-- クリップボードの設定
vim.o.clipboard = "unnamedplus"

if os.getenv("SSH_CONNECTION") ~= nil then
  local function paste()
    return {
      vim.fn.split(vim.fn.getreg(""), "\n"),
      vim.fn.getregtype(""),
    }
  end

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
