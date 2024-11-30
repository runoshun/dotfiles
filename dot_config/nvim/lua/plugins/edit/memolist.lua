return {
	{
		"glidenote/memolist.vim",
		cmd = { "MemoNew", "MemoList", "MemoGrep" },
		keys = {
			{ "<leader>mm", "<cmd>MemoNew<cr>",                  desc = "Create a new memo" },
			{ "<leader>mf", "<cmd>Telescope memo list<cr>",      desc = "Find memos" },
			{ "<leader>mw", "<cmd>Telescope memo live_grep<cr>", desc = "Grep memos" },
			{ "<leader>mP", "<cmd>!memo push<cr>",               desc = "Push memos to Git" },
			{ "<leader>mp", "<cmd>!memo pull<cr>",               desc = "Pull memos from Git" },
		},
		dependencies = {
			"nvim-telescope/telescope.nvim",
			"delphinus/telescope-memo.nvim",
		},
		config = function()
			vim.g.memolist_path = "~/.config/memo/_posts"
			vim.g.memolist_memo_suffix = "md"
			vim.g.memolist_fzf = 1

			require("telescope").load_extension("memo")
		end,
	},
}
