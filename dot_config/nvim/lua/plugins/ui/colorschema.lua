return {
  {
    "catppuccin/nvim",
    optional = true,
    opts = function(_, opts)
      opts.transparent_background = true
      return opts
    end,
  },
}
