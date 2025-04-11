--- @type LazySpec
return {
	{
		"zk-org/zk-nvim",
		event = "VeryLazy",
		config = function()
			require("zk").setup({
				picker = "snacks_picker",
			})
			local function map(...)
				vim.api.nvim_set_keymap(...)
			end
			local opts = { noremap = true, silent = false }
			map(
				"n",
				"<leader>zn",
				"<Cmd>ZkNew { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
				opts
			)
			map("v", "<leader>znt", ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<CR>", opts)
			map(
				"v",
				"<leader>znc",
				":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<CR>",
				opts
			)

			map("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", opts)
			map("n", "<leader>zl", "<Cmd>ZkLinks<CR>", opts)
			map("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
			map("v", "<leader>za", ":'<,'>lua vim.lsp.buf.range_code_action()<CR>", opts)

			vim.api.nvim_create_autocmd({ "BufEnter" }, {
				pattern = { "*.md" },
				callback = function(ev)
					vim.keymap.set("n", "<CR>", function()
						local line = vim.api.nvim_get_current_line()
						local col = vim.fn.col(".")
						local word = vim.fn.expand("<cword>")
						local lnum = vim.fn.line(".")

						if line:sub(col, col) == "[" then
							return
						end

						if line:sub(col - 1, col - 1) == "]" then
							return
						end

						if line:sub(col - #word, col - #word) == "[" then
							return
						end

						if line:sub(col + #word, col + #word) == "]" then
							return
						end
						vim.lsp.buf.definition()
					end, { noremap = true, silent = true, buffer = ev.buf })
				end,
			})
		end,
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown" },
		config = function()
			vim.api.nvim_set_hl(0, "RenderMarkdownH1", { link = "St_ReplaceMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2", { link = "St_TerminalMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH3", { link = "St_ConfirmMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH4", { link = "St_NTerminalMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH5", { link = "St_InsertMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH6", { link = "St_SelectMode" })

			vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { link = "St_ReplaceMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { link = "St_TerminalMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { link = "St_ConfirmMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { link = "St_NTerminalMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { link = "St_InsertMode" })
			vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { link = "St_SelectMode" })
			require("render-markdown").setup({})
		end,
	},
	{
		"3rd/diagram.nvim",
		dependencies = {
			"3rd/image.nvim",
		},
		config = function()
			require("diagram").setup({
				integrations = {
					require("diagram.integrations.markdown"),
					require("diagram.integrations.neorg"),
				},
				renderer_options = {
					mermaid = {
						theme = "forest",
						scale = 2,
					},
					plantuml = {
						charset = "utf-8",
					},
					d2 = {
						theme_id = 1,
					},
					gnuplot = {
						theme = "dark",
						size = "800,600",
					},
				},
			})
		end,
	},
	{
		"3rd/image.nvim",
		event = "VeryLazy",
		opts = {
			backend = "kitty",
			processor = "magick_cli", -- or "magick_cli"
			integrations = {
				markdown = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
				},
				neorg = {
					enabled = true,
					clear_in_insert_mode = false,
					download_remote_images = true,
					only_render_image_at_cursor = false,
					filetypes = { "norg" },
				},
			},
			max_width = nil,
			max_height = nil,
			max_width_window_percentage = nil,
			max_height_window_percentage = 50,
			kitty_method = "normal",
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
		},
	},
}
