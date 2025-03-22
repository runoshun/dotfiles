return {
	{
		"hrsh7th/nvim-cmp",
		config = function(_, opts)
			local cmp = require("cmp")

			local cmp_mappings = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			})

			cmp_mappings["<Tab>"] = vim.NIL
			cmp_mappings["<S-Tab>"] = vim.NIL

			opts.mapping = cmp_mappings
			cmp.setup(opts)
		end,
	},
	{
		"github/copilot.vim",
		event = "BufEnter",
		config = function()
			vim.g.copilot_filetypes = {
				yaml = true,
				bash = true,
				python = true,
				markdown = true,
				typescript = true,
				javascript = true,
				lua = true,
			}
			vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
		end,
	},
}
