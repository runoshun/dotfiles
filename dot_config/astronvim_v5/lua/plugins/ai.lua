-- vim: foldmethod=marker

if true then
	--- {{{ copilot chat and aider
	--- @type LazySpec
	return {
		{
			"GeorgesAlkhouri/nvim-aider",
			cmd = {
				"AiderTerminalToggle",
				"AiderHealth",
			},
			keys = {
				{ "<leader>ai", "<cmd>AiderTerminalToggle<cr>", desc = "Open Aider" },
				{
					"<leader>as",
					"<cmd>AiderTerminalSend<cr>",
					desc = "Send to Aider",
					mode = { "n", "v" },
				},
				{ "<leader>ac", "<cmd>AiderQuickSendCommand<cr>", desc = "Send Command To Aider" },
				{ "<leader>ab", "<cmd>AiderQuickSendBuffer<cr>", desc = "Send Buffer To Aider" },
				{ "<leader>a+", "<cmd>AiderQuickAddFile<cr>", desc = "Add File to Aider" },
				{ "<leader>a-", "<cmd>AiderQuickDropFile<cr>", desc = "Drop File from Aider" },
				{ "<leader>ar", "<cmd>AiderQuickReadOnlyFile<cr>", desc = "Add File as Read-Only" },
				-- Example nvim-tree.lua integration if needed
				{
					"<leader>a+",
					"<cmd>AiderTreeAddFile<cr>",
					desc = "Add File from Tree to Aider",
					ft = "NvimTree",
				},
				{
					"<leader>a-",
					"<cmd>AiderTreeDropFile<cr>",
					desc = "Drop File from Tree from Aider",
					ft = "NvimTree",
				},
			},
			dependencies = {
				"folke/snacks.nvim",
				"nvim-tree/nvim-tree.lua",
			},
			config = true,
			opts = {
				args = {
					"--pretty",
					"--stream",
					"--env-file ~/.aider.env",
				},
				win = {
					position = "right",
					width = 70,
				},
			},
		},
		{
			"CopilotC-Nvim/CopilotChat.nvim",
			version = "^2",
			enable = false,
			cmd = {
				"CopilotChat",
				"CopilotChatOpen",
				"CopilotChatClose",
				"CopilotChatToggle",
				"CopilotChatStop",
				"CopilotChatReset",
				"CopilotChatSave",
				"CopilotChatLoad",
				"CopilotChatDebugInfo",
				"CopilotChatModels",
				"CopilotChatExplain",
				"CopilotChatReview",
				"CopilotChatFix",
				"CopilotChatOptimize",
				"CopilotChatDocs",
				"CopilotChatFixDiagnostic",
				"CopilotChatCommit",
				"CopilotChatCommitStaged",
			},
			dependencies = {
				{ "zbirenbaum/copilot.lua" },
				{ "nvim-lua/plenary.nvim" },
				{ "nvim-telescope/telescope.nvim" },
			},
			keys = {
				{ "<leader>aa", "<cmd>CopilotChat<cr>", { silent = true, desc = "Open Copilot Chat" } },
			},
			config = function()
				-- Disable the enable_claude function
				local Copilot = require("CopilotChat.copilot")
				Copilot.enable_claude = function() end

				require("CopilotChat").setup({
					model = "claude-3.7-sonnet",
					context = "buffer",
					show_help = false,
					window = {
						layout = "vertical",
						width = 74, -- absolute width in columns
						height = vim.o.lines - 4, -- absolute height in rows, subtract for command line and status line
					},
					mappings = {
						reset = {
							normal = "<C-x>",
							insert = "<C-x>",
						},
					},
					prompts = {
						Explain = {
							prompt = "/COPILOT_EXPLAIN アクティブな選択範囲の説明を段落形式で書いてください。日本語で返答ください。",
						},
						Review = {
							prompt = "/COPILOT_REVIEW 選択されたコードをレビューしてください。日本語で返答ください。",
						},
						FixCode = {
							prompt = "/COPILOT_GENERATE このコードには問題があります。バグを修正したコードに書き直してください。日本語で返答ください。",
						},
						Refactor = {
							prompt = "/COPILOT_GENERATE 明瞭性と可読性を向上させるために、次のコードをリファクタリングしてください。日本語で返答ください。",
						},
						BetterNamings = {
							prompt = "/COPILOT_GENERATE 選択されたコードの変数名や関数名を改善してください。日本語で返答ください。",
						},
						Docs = {
							prompt = "/COPILOT_GENERATE 選択範囲にドキュメントコメントを追加してください。日本語で返答ください。",
						},
						Tests = {
							prompt = "/COPILOT_GENERATE コードのテストを生成してください。日本語で返答ください。",
						},
						Wording = {
							prompt = "/COPILOT_GENERATE 次のテキストの文法と表現を改善してください。日本語で返答ください。",
						},
						Summarize = {
							prompt = "/COPILOT_GENERATE 選択範囲の要約を書いてください。日本語で返答ください。",
						},
						Spelling = {
							prompt = "/COPILOT_GENERATE 次のテキストのスペルミスを修正してください。日本語で返答ください。",
						},
						FixDiagnostic = {
							prompt = "ファイル内の次の問題を支援してください:",
						},
						Commit = {
							prompt = "変更のコミットメッセージをcommitizenの規約に従って日本語で書いてください。タイトルは最大50文字、メッセージは72文字で折り返してください。メッセージ全体をgitcommit言語のコードブロックで囲んでください。",
						},
						CommitStaged = {
							prompt = "変更のコミットメッセージをcommitizenの規約に従って日本語で書いてください。タイトルは最大50文字、メッセージは72文字で折り返してください。メッセージ全体をgitcommit言語のコードブロックで囲んでください。",
						},
					},
				})
			end,
		},
	}
	--- }}}
end

if false then
	--- {{{ avante.nvim
	--- @type LazySpec
	return {
		{
			"yetone/avante.nvim",
			event = "VeryLazy",
			version = false, -- Never set this value to "*"! Never!
			opts = {
				provider = "openrouter_gemini25_free",
				auto_suggestions_provider = nil,
				-- cursor_applying_provider = "groq_llama33",
				behaviour = {
					-- enable_cursor_planning_mode = true,
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
					"NPM_CONFIG_PREFIX="
						.. vim.fs.joinpath(vim.fn.stdpath("data"), "mcp-hub")
						.. " npm install -g mcp-hub"
				)
			end,
			opts = {
				config = vim.fs.joinpath(vim.fn.stdpath("config"), "config", "mcp-hub.json"),
				cmd = vim.fs.joinpath(vim.fn.stdpath("data"), "mcp-hub", "bin", "mcp-hub"),
			},
		},
	}
	--- }}}
end
