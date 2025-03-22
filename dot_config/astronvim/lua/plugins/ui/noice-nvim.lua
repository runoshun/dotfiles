return {
	{
		"folke/noice.nvim",
		opts = {
			messages = {
				enabled = false,
			},
			notify = {
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
		},
	},
}
