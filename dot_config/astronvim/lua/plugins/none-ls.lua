---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    local null_ls = require("null-ls")

    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      null_ls.builtins.formatting.biome.with({
        can_run = function()
          -- if biome.json exists in the root directory
          print(vim.fn.expand("%:p:h") .. "/biome.json")
          return vim.fn.filereadable(vim.fn.expand("%:p:h") .. "/biome.json")
        end,
      }),
    })
  end,
}
