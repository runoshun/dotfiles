local utils = require("utils.utils")

return {
	{
		"AstroNvim/astrolsp",
		optional = true,
		---@type AstroLSPOpts
		opts = {
			---@diagnostic disable: missing-fields
			config = {
				ruff = {
					on_attach = function(client)
						client.server_capabilities.hoverProvider = false
					end,
				},
				basedpyright = {
					before_init = function(_, c)
						if not c.settings then
							c.settings = {}
						end
						if not c.settings.python then
							c.settings.python = {}
						end
						c.settings.python.pythonPath = vim.fn.exepath("python")
					end,
					settings = {
						require("lspconfig").basedpyright.setup {
						basedpyright = {
							analysis = {
        				diagnosticMode = "openFilesOnly",
        				inlayHints = {
        				  callArgumentNames = true
        				},
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
				},
			},
		},
	},
	{
		"linux-cultist/venv-selector.nvim",
		branch = "regexp",
		dependencies = { "neovim/nvim-lspconfig" },
		opts = {
			picker = "native",
		},
		event = "VeryLazy",
		keys = {
			{ "<leader>lV", "<cmd>VenvSelect<cr>" },
		},
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		optional = true,
		opts = function(_, opts)
			opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "ruff", "basedpyright" })
		end,
	},
}
