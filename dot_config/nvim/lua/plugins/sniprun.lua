local function run_between_markers()
	-- Get current cursor position
	local cursor_pos = vim.api.nvim_win_get_cursor(0)
	local curr_line = cursor_pos[1]
	local curr_buf = vim.api.nvim_get_current_buf()
	local line_count = vim.api.nvim_buf_line_count(curr_buf)

	-- Find the first "%%" above current line (or line 1)
	local start_line = 1
	for i = curr_line - 1, 1, -1 do
		local line_content = vim.api.nvim_buf_get_lines(curr_buf, i - 1, i, false)[1]
		if line_content:match("%%%%") then
			start_line = i + 1
			break
		end
	end

	-- Find the first "%%" below current line (or last line)
	local end_line = line_count
	for i = curr_line + 1, line_count do
		local line_content = vim.api.nvim_buf_get_lines(curr_buf, i - 1, i, false)[1]
		if line_content:match("%%%%") then
			end_line = i - 1
			break
		end
	end

	require("sniprun.api").run_range(start_line, end_line)
end

--- @type LazySpec
return {
	{
		"michaelb/sniprun",
		branch = "master",
		build = "sh install.sh",
		cmd = {
			"SnipRun",
		},
		keys = {
			{ "<leader>rr", run_between_markers, desc = "Run Snippet" },
			{ "<leader>rr", "<Plug>SnipRun", desc = "Run Snippet", mode = "v" },
			{ "<leader>rc", "<Plug>SnipClose", desc = "Close sniprun" },
		},
		config = function()
			require("sniprun").setup({
				display = {
					"TempFloatingWindow",
				},
				selected_interpreters = { "JS_TS_deno" },
				repl_enable = { "JS_TS_deno" },
			})
		end,
	},
}
