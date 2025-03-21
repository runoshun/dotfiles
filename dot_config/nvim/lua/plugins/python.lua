local utils = require "utils"

utils.on_very_lazy(function()
  local lspconfig = require "lspconfig"
  lspconfig.basedpyright.setup {}
  lspconfig.ruff.setup {}
end)

return {
  "linux-cultist/venv-selector.nvim",
  branch = "regexp",
  dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
  opts = {
    -- Your options go here
    -- name = "venv",
    -- auto_refresh = false
  },
  event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
  keys = {
    { "<leader>lV", "<cmd>VenvSelect<cr>" },
    { "<leader>lv", "<cmd>VenvSelectCached<cr>" },
  },
}
