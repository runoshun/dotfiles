--- @type LazySpec
return {
	{
		"obsidian-nvim/obsidian.nvim",
		version = "*",
		lazy = true,
		ft = "markdown",
		-- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
		-- event = {
		--   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
		--   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
		--   -- refer to `:h file-pattern` for more examples
		--   "BufReadPre path/to/my-vault/*.md",
		--   "BufNewFile path/to/my-vault/*.md",
		-- },
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = function(_, opts)
			vim.o.conceallevel = 1
			opts.workspaces = {
				{
					name = "personal",
					path = "~/notebook/personal",
				},
				{
					name = "work",
					path = "~/notebook/work",
				},
			}
			opts.picker = {
				name = "snacks.pick",
			}
			opts.completion = {
				nvim_cmp = false,
				blink = true,
				min_chars = 2,
			}
			return opts
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
			editor_only_render_when_focused = true,
			kitty_method = "normal",
			hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
		},
	},
}
