local utils = require("utils.utils")

utils.on_very_lazy(function()
	local lspconfig = require("lspconfig")
	lspconfig.basedpyright.setup({
		settings = {
			basedpyright = {
				analysis = {
					typeCheckingMode = "basic",
					autoImportCompletions = true,
					diagnosticSeverityOverrides = {
						reportUnusedImport = "information",
						reportUnusedFunction = "information",
						reportUnusedVariable = "information",
						reportGeneralTypeIssues = "none",
						reportOptionalMemberAccess = "none",
						reportOptionalSubscript = "none",
						reportPrivateImportUsage = "none",
					},
				},
			},
		},
	})
	lspconfig.ruff.setup({})
end)

return {
	"linux-cultist/venv-selector.nvim",
	branch = "regexp",
	dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
	opts = {
		-- Your options go here
		-- name = "venv",
		-- auto_refresh = false
	},
	event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
	keys = {
		{ "<leader>lV", "<cmd>VenvSelect<cr>" },
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "ruff", "basedpyright" })
		end,
	},
}
