-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
	"AstroNvim/astrocommunity",

	-- colorscheme
	-- { import = "astrocommunity.colorscheme.nordic-nvim" },
	{ import = "astrocommunity.colorscheme.nord-nvim" },
	-- { import = "astrocommunity.colorscheme.sonokai" },
	{ import = "astrocommunity.colorscheme.catppuccin" },
	{ import = "astrocommunity.colorscheme.iceberg-vim" },
	{ import = "astrocommunity.colorscheme.hybrid-nvim" },
	-- { import = "astrocommunity.colorscheme.kanagawa-nvim" },
	-- { import = "astrocommunity.colorscheme.kanagawa-paper-nvim" },
	-- { import = "astrocommunity.colorscheme.github-nvim-theme" },
	-- { import = "astrocommunity.colorscheme.onedarkpro-nvim" },
	-- { import = "astrocommunity.colorscheme.miasma-nvim" },
	-- { import = "astrocommunity.colorscheme.monokai-pro-nvim" },

	-- packs
	{ import = "astrocommunity.pack.kotlin" },
	{ import = "astrocommunity.pack.python-ruff" },
	{ import = "astrocommunity.pack.typescript-all-in-one" },
	{ import = "astrocommunity.pack.rust" },
	{ import = "astrocommunity.pack.bash" },
	{ import = "astrocommunity.pack.markdown" },
	{ import = "astrocommunity.pack.yaml" },
	{ import = "astrocommunity.pack.mdx" },
	{ import = "astrocommunity.pack.java" },

	-- misc
	{ import = "astrocommunity.editing-support.copilotchat-nvim" },
	{ import = "astrocommunity.docker.lazydocker" },
	{ import = "astrocommunity.scrolling.nvim-scrollbar" },
	{ import = "astrocommunity.git.diffview-nvim" },
	{ import = "astrocommunity.file-explorer.telescope-file-browser-nvim" },
	{ import = "astrocommunity.utility.telescope-live-grep-args-nvim" },
}
