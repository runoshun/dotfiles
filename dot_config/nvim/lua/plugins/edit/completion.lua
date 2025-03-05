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
		event = "InsertEnter",
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
	-- {
	-- 	"olimorris/codecompanion.nvim",
	-- 	dependencies = {
	-- 		"nvim-lua/plenary.nvim",
	-- 		{ "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
	-- 	},
	-- 	config = true,
	-- },
	{
		"olimorris/codecompanion.nvim",
		event = "BufEnter",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			-- "hrsh7th/nvim-cmp",                   -- Optional: For using slash commands and variables in the chat buffer
			-- "nvim-telescope/telescope.nvim",      -- Optional: For using slash commands
			-- { "stevearc/dressing.nvim", opts = {} }, -- Optional: Improves `vim.ui.select`
		},
		config = true,
		opts = {
			strategies = {
				chat = {
					adapter = "copilot",
				},
				inline = {
					adapter = "copilot",
				},
			},
		},
	},
}
