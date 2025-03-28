local utils = require("utils.utils")

--- @type table<string, boolean>
local isin_deno_project_memo = {}

local isin_deno_project = function(bufnr)
	local fname = vim.api.nvim_buf_get_name(bufnr)
	local dir = vim.fs.dirname(fname)

	if isin_deno_project_memo[dir] ~= nil then
		return isin_deno_project_memo[dir]
	end

	while true do
		if dir == "/" or dir == "" then
			break
		end

		if vim.fn.filereadable(vim.fs.joinpath(dir, "deno.json")) == 1 then
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
	if curr_client and curr_client.name == "denols" then
		if isin_deno_project(bufnr) then
			local clients = vim.lsp.get_clients({
				bufnr = bufnr,
				name = "vtsls",
			})
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id, true)
			end
		else
			vim.lsp.stop_client(curr_client.id, true)
		end
	end
end)

utils.on_very_lazy(function()
	require("lspconfig").vtsls.setup({})
	require("lspconfig").denols.setup({})
	require("lspconfig").biome.setup({})
	require("lspconfig").tailwindcss.setup({})
end)

return {
	{
		"sigmasd/deno-nvim",
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		opts = function(_, opts)
			opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "tailwindcss-language-server" })
		end,
	},
}
