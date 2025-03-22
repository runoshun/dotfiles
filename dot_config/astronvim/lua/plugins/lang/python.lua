return {
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(v)
        return not vim.tbl_contains({ "black", "isort" }, v)
      end, opts.ensure_installed)
    end,
  },
}
