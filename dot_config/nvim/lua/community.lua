-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- colorscheme
  --{ import = "astrocommunity.colorscheme.nordic-nvim" },
  --{ import = "astrocommunity.colorscheme.sonokai" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  --{ import = "astrocommunity.colorscheme.kanagawa-paper-nvim" },
  { import = "astrocommunity.colorscheme.github-nvim-theme" },
  { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  --{ import = "astrocommunity.colorscheme.miasma-nvim" },
  { import = "astrocommunity.colorscheme.monokai-pro-nvim" },

  { import = "astrocommunity.pack.python-ruff" },

  { import = "astrocommunity.code-runner.molten-nvim" },
}
