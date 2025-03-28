local utils = require("utils.utils")

utils.on_very_lazy(function()
	local lspconfig = require("lspconfig")
	local jsonls_caps = vim.lsp.protocol.make_client_capabilities()
	jsonls_caps.textDocument.completion.completionItem.snippetSupport = true

	require("lspconfig").jsonls.setup({
		capabilities = jsonls_caps,
		filetypes = { "json", "jsonc" },
		settings = {
			json = {
				schemas = require("schemastore").json.schemas(),
				validate = { enable = true },
			},
		},
	})

	local yamlls_caps = vim.lsp.protocol.make_client_capabilities()
	yamlls_caps.textDocument.completion.completionItem.snippetSupport = true
	require("lspconfig").yamlls.setup({
		capabilities = yamlls_caps,
		settings = {
			yaml = {
				schemaStore = {
					enable = false,
					url = "",
				},
				schemas = require("schemastore").yaml.schemas(),
			},
		},
	})
end)

return {
	{
		"b0o/schemastore.nvim",
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed =
				utils.list_insert_unique(opts.ensure_installed, { "json-lsp", "yaml-language-server" })
			return opts
		end,
	},
}
