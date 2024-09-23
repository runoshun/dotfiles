---@type LazySpec
return {
  {
    "gbprod/yanky.nvim",
    event = "VeryLazy",
    dependencies = {
      { "kkharji/sqlite.lua", enabled = not jit.os:find("Windows") },
    },
    opts = {},
    keys = {
      { "p",     "<Plug>(YankyPutAfter)" },
      { "P",     "<Plug>(YankyPutBefore)" },
      { "gp",    "<Plug>(YankyGPutAfter)" },
      { "gP",    "<Plug>(YankyGPutBefore)" },

      { "p",     "<Plug>(YankyPutAfter)" },
      { "P",     "<Plug>(YankyPutBefore)" },
      { "gp",    "<Plug>(YankyGPutAfter)" },
      { "gP",    "<Plug>(YankyGPutBefore)" },

      { "<C-p>", "<Plug>(YankyPreviousEntry)" },
      { "<C-n>", "<Plug>(YankyNextEntry)" },
    },
  },
}
