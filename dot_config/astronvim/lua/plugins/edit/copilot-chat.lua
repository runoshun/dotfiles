---@type LazySpec
return {
	"CopilotC-Nvim/CopilotChat.nvim",
	version = "^2",
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
		{
			"AstroNvim/astrocore",
			---@param opts AstroCoreOpts
			opts = function(_, opts)
				local maps = assert(opts.mappings)
				local prefix = opts.options.g.copilot_chat_prefix or "<Leader>a"
				local astroui = require("astroui")

				maps.n[prefix] = { desc = astroui.get_icon("CopilotChat", 1, true) .. "CopilotChat" }
				maps.v[prefix] = { desc = astroui.get_icon("CopilotChat", 1, true) .. "CopilotChat" }

				maps.n[prefix .. "o"] = { ":CopilotChatOpen<CR>", desc = "Open Chat" }
				maps.n[prefix .. "c"] = { ":CopilotChatClose<CR>", desc = "Close Chat" }
				maps.n[prefix .. "r"] = { ":CopilotChatReset<CR>", desc = "Reset Chat" }
				maps.n[prefix .. "s"] = { ":CopilotChatStop<CR>", desc = "Stop Chat" }
				maps.n[prefix .. "d"] = { ":CopilotChatDebugInfo<CR>", desc = "Debug Info" }
				maps.n[prefix .. "?"] = { ":CopilotChatModels<CR>", desc = "Select Models" }

				maps.n[prefix .. "f"] = { ":CopilotChatFixDiagnostic<CR>", desc = "Fix Diagnostic" }

				maps.v[prefix .. "f"] = { "<cmd>CopilotChatFixDiagnostic<CR>", desc = "Fix Diagnostic" }
				maps.v[prefix .. "e"] = { "<cmd>CopilotChatExplain<CR>", desc = "Explain code" }
				maps.v[prefix .. "t"] = { "<cmd>CopilotChatTests<CR>", desc = "Generate tests" }
				maps.v[prefix .. "r"] = { "<cmd>CopilotChatReview<CR>", desc = "Review code" }
				maps.v[prefix .. "R"] = { "<cmd>CopilotChatRefactor<CR>", desc = "Refactor code" }
				maps.v[prefix .. "d"] = { "<cmd>CopilotChatDocs<CR>", desc = "Generate docs" }

				maps.n[prefix .. "S"] = {
					function()
						vim.ui.input({ prompt = "Save Chat: " }, function(input)
							if input ~= nil and input ~= "" then
								require("CopilotChat").save(input)
							end
						end)
					end,
					desc = "Save Chat",
				}

				maps.n[prefix .. "L"] = {
					function()
						local copilot_chat = require("CopilotChat")
						local path = copilot_chat.config.history_path
						local chats = require("plenary.scandir").scan_dir(path, { depth = 1, hidden = true })
						-- Remove the path from the chat names and .json
						for i, chat in ipairs(chats) do
							chats[i] = chat:sub(#path + 2, -6)
						end
						vim.ui.select(chats, { prompt = "Load Chat: " }, function(selected)
							if selected ~= nil and selected ~= "" then
								copilot_chat.load(selected)
							end
						end)
					end,
					desc = "Load Chat",
				}

				-- Helper function to create mappings
				local function create_mapping(action_type, selection_type)
					return function()
						require("CopilotChat.integrations.telescope").pick(require("CopilotChat.actions")[action_type]({
							selection = require("CopilotChat.select")[selection_type],
						}))
					end
				end

				maps.n[prefix .. "p"] = {
					create_mapping("prompt_actions", "buffer"),
					desc = "Prompt actions",
				}

				maps.v[prefix .. "p"] = {
					create_mapping("prompt_actions", "visual"),
					desc = "Prompt actions",
				}

				maps.n[prefix .. "l"] = {
					create_mapping("help_actions", "buffer"),
					desc = "LSP Diagnostics actions",
				}

				maps.v[prefix .. "l"] = {
					create_mapping("help_actions", "visual"),
					desc = "LSP Diagnostics actions",
				}

				-- Quick Chat function
				local function quick_chat(selection_type)
					return function()
						vim.ui.input({ prompt = "Quick Chat: " }, function(input)
							if input ~= nil and input ~= "" then
								require("CopilotChat").ask(
									input,
									{ selection = require("CopilotChat.select")[selection_type] }
								)
							end
						end)
					end
				end

				maps.n[prefix .. "q"] = {
					quick_chat("buffer"),
					desc = "Quick Chat",
				}

				maps.v[prefix .. "q"] = {
					quick_chat("visual"),
					desc = "Quick Chat",
				}
			end,
		},
		{ "AstroNvim/astroui", opts = { icons = { CopilotChat = "" } } },
	},
	config = function()
		-- Disable the enable_claude function
		local Copilot = require("CopilotChat.copilot")
		Copilot.enable_claude = function() end

		require("CopilotChat").setup({
			model = "claude-3.5-sonnet",
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
}
