---@type LazySpec
return {
	"nvimtools/none-ls.nvim",
	opts = function(_, opts)
		local null_ls = require("null-ls")

		opts.sources = require("astrocore").list_insert_unique(opts.sources, {})
	end,
}
