-- vim: foldmethod=marker :

-- @type "avante" | "codecompanion" | "copilot-chat" | "ai-terminal" | "claude-code"
local using = "claude-code"
local enable_aider = false

--- @type LazySpec
local plugins = {}

if enable_aider then
	--- {{{ aider
	local valid_aider_env_toggles = {
		{
			name = "Restore Chat History",
			env_var = "AIDER_RESTORE_CHAT_HISTORY",
			default_value = "false",
		},
		{
			name = "Enable Auto Commits",
			env_var = "AIDER_AUTO_COMMITS",
			default_value = "true",
		},
		{
			name = "Enable Subtree Only",
			env_var = "AIDER_SUBTREE_ONLY",
			default_value = "false",
		},
		{
			name = "Enable prompt caching",
			env_var = "AIDER_CACHE_PROMPTS",
			default_value = "false",
		},
		{
			name = "Enable watch files",
			env_var = "AIDER_WATCH_FILES",
			default_value = "false",
		},
	}

	-- Recursive function to handle the selection UI
	local function select_recursive(current_active_states, available_toggles, last_selected_display_name)
		local toggle_map = {}
		local display_opts = {}
		for _, toggle in ipairs(available_toggles) do
			local state_str = current_active_states[toggle.name] and "✓" or " "
			local display_name = string.format("[%s] %s", state_str, toggle.name)
			table.insert(display_opts, display_name)
			toggle_map[display_name] = toggle
		end
		local DONE = " >>> Done"
		local CANCEL = " --- Cancel"
		table.insert(display_opts, DONE)
		table.insert(display_opts, CANCEL)

		vim.ui.select(display_opts, {
			prompt = "Toggle Aider setting (or Done/Cancel):",
			format_item = function(item)
				return item
			end,
			default_choice = last_selected_display_name, -- Highlight the last selected item
		}, function(choice)
			if not choice or choice == CANCEL then
				vim.notify("Aider launch cancelled.", vim.log.levels.INFO)
				return
			end

			if choice == DONE then
				for _, toggle in ipairs(available_toggles) do
					local final_value_for_env
					if current_active_states[toggle.name] then
						final_value_for_env = "true"
					else
						final_value_for_env = "false"
					end

					if final_value_for_env == toggle.default_value then
						vim.fn.setenv(toggle.env_var, nil)
					else
						vim.fn.setenv(toggle.env_var, final_value_for_env)
					end
				end

				require("nvim_aider").api.toggle_terminal()
				return
			end

			local selected_toggle = toggle_map[choice]
			if selected_toggle then
				current_active_states[selected_toggle.name] = not current_active_states[selected_toggle.name]
				select_recursive(current_active_states, available_toggles, choice)
			else
				vim.notify("Invalid selection logic error", vim.log.levels.ERROR)
			end
		end)
	end

	local function toggle_aider_with_opts()
		local initial_active_states = {}
		for _, toggle in ipairs(valid_aider_env_toggles) do
			local current_env_value = vim.fn.getenv(toggle.env_var)
			local effective_value = (current_env_value ~= vim.NIL) and current_env_value or toggle.default_value
			initial_active_states[toggle.name] = (effective_value == "true")
		end
		select_recursive(initial_active_states, valid_aider_env_toggles, nil)
	end

	local aider = {
		{
			"GeorgesAlkhouri/nvim-aider",
			cmd = {
				"Aider",
			},
			keys = {
				{ "<leader>aI", toggle_aider_with_opts, desc = "Toggle Aider with env toggles" },
				{ "<leader>ai", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
				{ "<leader>a0", "<cmd>Aider add<cr>", desc = "Add File" },
				{ "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
				{ "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
			},
			dependencies = {
				"folke/snacks.nvim",
				{
					"nvim-neo-tree/neo-tree.nvim",
					opts = function(_, opts)
						if opts.window == nil then
							opts.window = {}
						end
						if opts.window.mappings == nil then
							opts.window.mappings = {}
						end

						opts.window.mappings["0"] = { "nvim_aider_add", desc = "add to aider" }
						opts.window.mappings["-"] = { "nvim_aider_add_readonly", desc = "add readonly to aider" }
						require("nvim_aider.neo_tree").setup(opts)
					end,
				},
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
	}
	table.insert(plugins, aider)
	--- }}}
end

if using == "claude-code" then
	--- {{{ claude-code.nvim
	--- @type LazySpec
	table.insert(plugins, {
		"coder/claudecode.nvim",
		dependencies = { "folke/snacks.nvim" },
		config = true,
		keys = {
			{ "<leader>a", nil, desc = "AI/Claude Code" },
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
			{ "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
			{
				"<leader>as",
				"<cmd>ClaudeCodeTreeAdd<cr>",
				desc = "Add file",
				ft = { "NvimTree", "neo-tree", "oil" },
			},
			-- Diff management
			{ "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
		},
	})
	--- }}}
end

if using == "copilot-chat" then
	--- {{{ copilot chat
	--- @type LazySpec
	plugins.insert({
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
	})
	--- }}}
end

if using == "codecompanion" then
	--- {{{ codecompanion.nvim
	table.insert(plugins, {
		"olimorris/codecompanion.nvim",
		config = true,
		opts = function(_, opts)
			local default_model = "deepseek/deepseek-chat-v3-0324:free"
			local available_models = {
				"deepseek/deepseek-chat-v3-0324:free",
				"deepseek/deepseek-chat-v3-0324",
				"google/gemini-2.0-flash-001",
				"google/gemini-2.5-pro-preview-03-25:free",
				"anthropic/claude-3.7-sonnet",
				"openrouter/quasar-alpha",
			}
			local current_model = default_model

			local function select_model()
				vim.ui.select(available_models, {
					prompt = "Select  Model:",
				}, function(choice)
					if choice then
						current_model = choice
						vim.notify("Selected model: " .. current_model)
					end
				end)
			end

			local env_opts = require("env.code-companion")
			local base_opts = {
				language = "Japanese",
				adapters = {
					openrouter = function()
						return require("codecompanion.adapters").extend("openai_compatible", {
							env = {
								url = "https://openrouter.ai/api",
								api_key = "OPENROUTER_API_KEY",
								chat_url = "/v1/chat/completions",
							},
							schema = {
								model = {
									default = current_model,
								},
							},
							body = {
								provider = {
									sort = "throughput",
									ignore = { "SambaNova" },
								},
							},
						})
					end,
				},
				display = {
					diff = {
						enabled = true,
						close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
						layout = "vertical", -- vertical|horizontal split for default provider
						opts = {
							"internal",
							"filler",
							"closeoff",
							"algorithm:patience",
							"followwrap",
							"linematch:120",
						},
						provider = "mini_diff", -- default|mini_diff
					},
				},
				strategies = {
					chat = {
						adapter = "openrouter",
						roles = {
							llm = function(adapter)
								return "  CodeCompanion (" .. adapter.formatted_name .. ")"
							end,
							user = "  Me",
						},
						tools = {
							["mcp"] = {
								callback = require("mcphub.extensions.codecompanion"),
								description = "Call tools and resources from the MCP Servers",
								opts = {
									user_approval = true,
								},
							},
						},
					},
					inline = {
						adapter = "openrouter",
					},
				},
			}

			vim.keymap.set("n", "<leader>am", function()
				select_model()
			end, { desc = "Select CodeCompanion Model" })
			vim.keymap.set(
				{ "n", "v" },
				"<leader>aa",
				"<cmd>CodeCompanionActions<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set(
				{ "n", "v" },
				"<leader>ac",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ noremap = true, silent = true }
			)
			vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

			return vim.tbl_deep_extend("force", opts, base_opts, env_opts)
		end,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			{ "echasnovski/mini.diff", version = "*" },
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
					extensions = {
						codecompanion = {
							show_result_in_chat = true,
							make_vars = true,
							make_slash_commands = true,
						},
					},
				},
			},
		},
	})
	--- }}}
end

if using == "avante" then
	--- {{{ avante.nvim
	--- @type LazySpec
	table.insert(plugins, {
		"yetone/avante.nvim",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		opts = {
			provider = "openrouter_gemini25_free",
			auto_suggestions_provider = nil,
			-- cursor_applying_provider = "groq_llama33",
			behaviour = {
				-- enable_cursor_planning_mode = true,
				auto_apply_diff_after_generation = false,
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
	})
	table.insert(plugins, {
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
	})
	--- }}}
end

return plugins
