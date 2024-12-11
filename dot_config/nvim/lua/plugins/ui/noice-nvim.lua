return {
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			messages = {
				enabled = false,
			},
			lsp = {
				hover = {
					enabled = false,
				},
				signature = {
					enabled = false,
				},
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
			"rcarriga/nvim-notify",
		},
	},
}
