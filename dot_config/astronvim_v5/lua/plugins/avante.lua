--- @type LazySpec
return {
	{
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "openrouter_gemini25_free",
			auto_suggestions_provider = nil,
			cursor_applying_provider = "groq_llama33",
			behaviour = {
				enable_cursor_planning_mode = true,
				auto_apply_diff_after_generation = true,
			},
			copilot = {
				model = "claude-3.7-sonnet",
			},
			file_selector = {
				provider = "snacks",
			},
			vendors = {
				groq_llama33 = {
					__inherited_from = "openai",
					endpoint = "https://api.groq.com/openai/v1/",
					api_key_name = "GROQ_API_KEY",
					model = "llama-3.3-70b-versatile",
				},
				openrouter_deepseek_free = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "deepseek/deepseek-chat-v3-0324:free",
				},
				openrouter_deepseek_paid = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "deepseek/deepseek-chat-v3-0324",
				},
				openrouter_gemini25_free = {
					__inherited_from = "openai",
					endpoint = "https://openrouter.ai/api/v1",
					api_key_name = "OPENROUTER_API_KEY",
					model = "google/gemini-2.5-pro-exp-03-25:free",
				},
			},
			mappings = {
				submit = {
					normal = "<CR>",
					insert = "<S-CR>",
				},
			},
			windows = {
				position = "smart",
			},
		},
		build = "make",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			{
				"saghen/blink.cmp",
				dependencies = {
					"Kaiser-Yang/blink-cmp-avante",
				},
				opts = {
					sources = {
						per_filetype = {
							AvanteInput = { "avante", "lsp", "path" },
						},
						providers = {
							avante = {
								module = "blink-cmp-avante",
								name = "Avante",
								opts = {},
							},
						},
					},
				},
			},
			--- The below dependencies are optional,
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		"ravitemer/mcphub.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		cmd = "MCPHub",
		native_servers = {},
		build = function()
			vim.fn.system(
				"NPM_CONFIG_PREFIX=" .. vim.fs.joinpath(vim.fn.stdpath("data"), "mcp-hub") .. " npm install -g mcp-hub"
			)
		end,
		opts = {
			config = vim.fs.joinpath(vim.fn.stdpath("config"), "config", "mcp-hub.json"),
			cmd = vim.fs.joinpath(vim.fn.stdpath("data"), "mcp-hub", "bin", "mcp-hub"),
		},
	},
}
