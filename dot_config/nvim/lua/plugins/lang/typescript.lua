return {
	{
		"AstroNvim/astrolsp",
		opts = {
			config = {
				biome = {
					root_dir = require("lspconfig.util").root_pattern("biome.json"),
				},
			},
		},
	},
	{
		"nvimtools/none-ls.nvim",
		optional = true,
		enabled = function()
			-- 編集中のファイルが biome.json が存在するプロジェクトに属しているかチェック
			return vim.fn.filereadable(vim.fn.expand("%:p:h") .. "/biome.json") == 1
		end,
		opts = function()
			local nls = require("null-ls")
			return {
				sources = {
					nls.builtins.formatting.biome,
				},
			}
		end,
	},
}
