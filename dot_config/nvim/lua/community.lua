-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",

  -- colorscheme
  -- { import = "astrocommunity.colorscheme.nordic-nvim" },
  -- { import = "astrocommunity.colorscheme.sonokai" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- { import = "astrocommunity.colorscheme.kanagawa-nvim" },
  -- { import = "astrocommunity.colorscheme.kanagawa-paper-nvim" },
  -- { import = "astrocommunity.colorscheme.github-nvim-theme" },
  -- { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
  -- { import = "astrocommunity.colorscheme.miasma-nvim" },
  -- { import = "astrocommunity.colorscheme.monokai-pro-nvim" },

  -- packs
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.typescript-all-in-one" },
  { import = "astrocommunity.pack.rust" },

  -- misc
  { import = "astrocommunity.editing-support.copilotchat-nvim" },
  { import = "astrocommunity.docker.lazydocker" },
}
