local utils = require("utils.utils")

--- @type table<string, boolean>
local isin_deno_project_memo = {}

local isin_deno_project = function(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.fs.dirname(fname)
	-- print("Checking if in Deno project: " .. dir)

	if isin_deno_project_memo[dir] ~= nil then
		return isin_deno_project_memo[dir]
	end

	while true do
		if dir == "/" or dir == "" then
			break
		end

		if vim.fn.filereadable(vim.fs.joinpath(dir, "deno.json")) == 1 then
			-- print("Found deno.json in: " .. dir)
			isin_deno_project_memo[dir] = true
			return true
		end

		if vim.fn.isdirectory(vim.fs.joinpath(dir, ".git")) == 1 then
			break
		end

		dir = vim.fs.dirname(dir)
	end

	isin_deno_project_memo[dir] = false
	return false
end

utils.on_lsp_attach(function(curr_client, bufnr)
	if curr_client and (curr_client.name == "denols" or curr_client.name == "vtsls") then
		if isin_deno_project(bufnr) then
			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
				name = "vtsls",
			})
			vim.lsp.stop_client(clients, true)
		else
			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
				name = "denols",
			})
			vim.lsp.stop_client(clients, true)
		end
	end
end)

utils.on_very_lazy(function()
	require("lspconfig").biome.setup({})
	require("lspconfig").tailwindcss.setup({})
end)

return {
	{
		"sigmasd/deno-nvim",
		ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
		dependencies = { { "AstroNvim/astrolsp", optional = true, opts = { handlers = { denols = false } } } },
		opts = function(_, opts)
			local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
			if astrolsp_avail then
				opts.server = astrolsp.lsp_opts("denols")
			end
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "tailwindcss-language-server" })
		end,
	},
	{
		"AstroNvim/astrolsp",
		---@type AstroLSPOpts
		opts = {
			autocmds = {
				eslint_fix_on_save = {
					cond = function(client)
						return client.name == "eslint" and vim.fn.exists(":EslintFixAll") > 0
					end,
					{
						event = "BufWritePost",
						desc = "Fix all eslint errors",
						callback = function(args)
							if vim.F.if_nil(vim.b[args.buf].autoformat, vim.g.autoformat, true) then
								vim.cmd.EslintFixAll()
							end
						end,
					},
				},
			},
			---@diagnostic disable: missing-fields
			config = {
				vtsls = {
					settings = {
						typescript = {
							updateImportsOnFileMove = { enabled = "always" },
							inlayHints = {
								parameterNames = { enabled = "all" },
								parameterTypes = { enabled = true },
								variableTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								enumMemberValues = { enabled = true },
							},
						},
						javascript = {
							updateImportsOnFileMove = { enabled = "always" },
							inlayHints = {
								parameterNames = { enabled = "literals" },
								parameterTypes = { enabled = true },
								variableTypes = { enabled = true },
								propertyDeclarationTypes = { enabled = true },
								functionLikeReturnTypes = { enabled = true },
								enumMemberValues = { enabled = true },
							},
						},
						vtsls = {
							enableMoveToFileCodeAction = true,
						},
					},
				},
			},
		},
	},
}
