-- vim: foldmethod=marker :

--- {{{ window_move_plugin
local window_move_plugin = (function()
	if vim.env.ZELLIJ ~= nil then
		--- @type LazySpec
		return {
			"swaits/zellij-nav.nvim",
			lazy = true,
			event = "VeryLazy",
			keys = {
				{ "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>", desc = "navigate left or tab", mode = "n" },
				{ "<c-j>", "<cmd>ZellijNavigateDown<cr>", desc = "navigate down", mode = "n" },
				{ "<c-k>", "<cmd>ZellijNavigateUp<cr>", desc = "navigate up", mode = "n" },
				{ "<c-l>", "<cmd>ZellijNavigateRightTab<cr>", desc = "navigate right or tab", mode = "n" },
			},
			opts = {},
		}
	else -- use tmux navigator
		vim.g.tmux_navigator_no_mappings = 1
		--- @type LazySpec
		return {
			"christoomey/vim-tmux-navigator",
			cmd = {
				"TmuxNavigateLeft",
				"TmuxNavigateDown",
				"TmuxNavigateUp",
				"TmuxNavigateRight",
				"TmuxNavigatePrevious",
				"TmuxNavigatorProcessList",
			},
			keys = {
				{ "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "navigate left", mode = "n" },
				{ "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "navigate down", mode = "n" },
				{ "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "navigate up", mode = "n" },
				{ "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "navigate right", mode = "n" },
				{ "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "navigate previous", mode = "n" },
				-- terminal
				{ "<C-h>", "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>", desc = "navigate left", mode = "t" },
				{ "<C-j>", "<C-\\><C-N><cmd>TmuxNavigateDown<cr>", desc = "navigate down", mode = "t" },
				{ "<C-k>", "<C-\\><C-N><cmd>TmuxNavigateUp<cr>", desc = "navigate up", mode = "t" },
				{ "<C-l>", "<C-\\><C-N><cmd>TmuxNavigateRight<cr>", desc = "navigate right", mode = "t" },
				{ "<C-\\>", "<C-\\><C-N><cmd>TmuxNavigatePrevious<cr>", desc = "navigate previous", mode = "t" },
			},
		}
	end
end)() -- }}}

---@type LazySpec
return {
	window_move_plugin,

	--- {{{ nvim-cmp and copilot.vim
	{
		"hrsh7th/nvim-cmp",
		config = function(_, opts)
			local cmp = require("cmp")

			local cmp_mappings = cmp.mapping.preset.insert({
				["<CR>"] = cmp.mapping.confirm({ select = false }),
			})

			cmp_mappings["<Tab>"] = vim.NIL
			cmp_mappings["<S-Tab>"] = vim.NIL

			opts.mapping = cmp_mappings
			cmp.setup(opts)
		end,
	},
	{
		"github/copilot.vim",
		event = "BufEnter",
		config = function()
			vim.g.copilot_filetypes = {
				yaml = true,
				bash = true,
				python = true,
				markdown = true,
				typescript = true,
				javascript = true,
				lua = true,
			}
			vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
				expr = true,
				replace_keycodes = false,
			})
		end,
	},
	--- }}}

	--- {{{ copilot-chat
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
	--- }}}

	--- {{{ nvim-aider
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
	--- }}}

	--- {{{ noice.nvim
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			views = {
				cmdline_popup = {
					position = { row = 20, col = "50%" },
					size = { width = 60, height = "auto" },
				},
				popupmenu = {
					relative = "editor",
					position = { row = 23, col = "50%" },
					size = { width = 60, height = 10 },
					border = { style = "rounded", padding = { 0, 1 } },
					win_options = {
						winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
					},
				},
			},
			cmdline = {
				enabled = true, -- enables the Noice cmdline UI
				view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
			},
			popupmenu = {
				enabled = true, -- enables the Noice popupmenu UI
			},
			messages = {
				enabled = false, -- enables the Noice messages UI
			},
			notify = {
				enabled = false,
			},
			lsp = {
				progress = {
					enabled = false,
				},
				hover = {
					enabled = false,
				},
				signature = {
					enabled = false,
				},
				message = {
					enabled = false,
				},
			},
			health = {
				checker = true,
			},
			presets = {
				bottom_search = false, -- use a classic bottom cmdline for search
				command_palette = false, -- position the cmdline and popupmenu together
				long_message_to_split = false, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		},
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
	},
	--- }}}

	--- {{{ snacks
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = function(_, opts)
			local get_icon = require("astroui").get_icon
			local buf_utils = require("astrocore.buffer")

			opts.picker = { layout = "default" }
			opts.image = { enabled = true }
			opts.scroll = {
				animate = {
					duration = { step = 5, total = 50 },
					easing = "linear",
				},
			}
			opts.words = { enabled = true }
			opts.dashboard = {
				preset = {
					keys = {
						{
							key = "n",
							action = "<Leader>n",
							icon = get_icon("FileNew", 0, true),
							desc = "New File  ",
						},
						{
							key = "f",
							action = "<Leader>ff",
							icon = get_icon("Search", 0, true),
							desc = "Find File  ",
						},
						{
							key = "o",
							action = "<Leader>fo",
							icon = get_icon("DefaultFile", 0, true),
							desc = "Recents  ",
						},
						{
							key = "w",
							action = "<Leader>fw",
							icon = get_icon("WordFile", 0, true),
							desc = "Find Word  ",
						},
						{
							key = "'",
							action = "<Leader>f'",
							icon = get_icon("Bookmarks", 0, true),
							desc = "Bookmarks  ",
						},
						{
							key = "s",
							action = "<Leader>Sl",
							icon = get_icon("Refresh", 0, true),
							desc = "Last Session  ",
						},
					},
					header = table.concat({
						[[                                  __                   ]],
						[[     ___     ___    ___   __  __ /\_\    ___ ___       ]],
						[[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\     ]],
						[[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \    ]],
						[[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\   ]],
						[[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/   ]],
					}, "\n"),
				},
				sections = {
					{ section = "header", padding = 5 },
					{ section = "keys", gap = 1, padding = 3 },
					{ section = "startup" },
				},
			}
			return opts
		end,
		keys = {
			{
				"<leader>..",
				function()
					require("snacks").scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>.S",
				function()
					require("snacks").scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>fp",
				function()
					require("snacks").picker.pickers()
				end,
				desc = "Snacks Pickers",
			},
		},
	},
	--- }}}

	--- {{{ nvim-treesitter-textsubjects
	{
		"RRethy/nvim-treesitter-textsubjects",
		event = "BufEnter",
		config = function()
			require("nvim-treesitter-textsubjects").configure({
				prev_selection = ",",
				keymaps = {
					["."] = "textsubjects-smart",
					[";"] = "textsubjects-container-outer",
					["i;"] = "textsubjects-container-inner",
				},
			})
		end,
	},
	--- }}}

	--- {{{ neo-tree
	{
		"nvim-neo-tree/neo-tree.nvim",
		opts = {
			sources = {
				"filesystem",
				"document_symbols",
				"git_status",
			},
			source_selector = {
				sources = {
					{ source = "filesystem" },
					{ source = "document_symbols" },
					{ source = "git_status" },
				},
			},
			filesystem = {
				filtered_items = {
					visible = true,
					show_hidden_count = true,
					hide_dotfiles = false,
					hide_gitignored = false,
					hide_by_name = {
						".git",
						".DS_Store",
						"thumbs.db",
					},
					never_show = {},
				},
			},
		},
	},
	--- }}}

	--- {{{ alpha-nvim
	{
		"goolord/alpha-nvim",
		opts = function(_, opts)
			local function button(sc, txt, keybind, keybind_opts)
				local leader = "SPC"
				local sc_ = sc:gsub("%s", ""):gsub(leader, "<leader>")

				local opts = {
					position = "center",
					shortcut = sc,
					cursor = 3,
					width = 60,
					align_shortcut = "right",
					hl = "DashboardCenter",
					hl_shortcut = "DashboardShortcut",
				}
				if keybind then
					keybind_opts = vim.F.if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
					opts.keymap = { "n", sc_, keybind, keybind_opts }
				end

				local function on_press()
					local key = vim.api.nvim_replace_termcodes(keybind or sc_ .. "<Ignore>", true, false, true)
					vim.api.nvim_feedkeys(key, "t", false)
				end

				return {
					type = "button",
					val = txt,
					on_press = on_press,
					opts = opts,
				}
			end

			local header = {
				type = "text",
				val = {
					[[                                  __                   ]],
					[[     ___     ___    ___   __  __ /\_\    ___ ___       ]],
					[[    / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\     ]],
					[[   /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \    ]],
					[[   \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\   ]],
					[[    \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/   ]],
				},
				opts = {
					position = "center",
					hl = "Type",
				},
			}
			local actions = {
				type = "group",
				val = {
					button("e", "  New file", ":ene <BAR> startinsert <CR>"),
					button("f", "  Find file", ":Telescope find_files<CR>"),
					button("r", "  Recent", ":Telescope oldfiles<CR>"),
					button("s", "  Sessions", ':lua require("resession").load(nil, { dir = "dirsession" })<CR>'),
					button("c", "  Configs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
				},
				opts = {
					spacing = 1,
				},
			}

			local sess = require("resession").list({ dir = "dirsession" })
			local sessions = {
				type = "group",
				val = {},
				opts = {
					spacing = 1,
				},
			}
			for i, s in ipairs(sess) do
				if i > 5 then
					break
				end

				local path = s:gsub("_", "/")
				path = path:gsub("^" .. os.getenv("HOME"), "~")
				path = path:len() > 40 and path:sub(1, 20) .. "..." .. path:sub(-20) or path

				local load_opts = '{ dir = "dirsession", attach = true, reset = "auto" }'
				table.insert(
					sessions.val,
					button(
						tostring(i),
						path,
						string.format(":lua require(\"resession\").load('%s', %s)<CR>", s, load_opts)
					)
				)
			end

			opts.config.layout = {
				{ type = "padding", val = 8 },
				header,
				{ type = "padding", val = 2 },

				-- sessions
				{ type = "text", val = "  Sessions", opts = { hl = "Title", position = "center" } },
				{ type = "padding", val = 1 },
				sessions,
				--

				{ type = "padding", val = 2 },

				-- actions
				{ type = "text", val = "⚡️ Actions", opts = { hl = "Title", position = "center" } },
				{ type = "padding", val = 1 },
				actions,
				--

				{ type = "padding", val = 2 },
				opts.section.footer,
			}
			return opts
		end,
	},
	--- }}}

	--- {{{ leap.nvim
	{
		"ggandor/leap.nvim",
		lazy = false,
		config = function()
			require("leap")
			vim.keymap.set({ "n", "x" }, "s", "<Plug>(leap)")
			vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
			vim.keymap.set("o", "s", "<Plug>(leap-forward)")
			vim.keymap.set("o", "S", "<Plug>(leap-backward)")
		end,
	},
	--- }}}

	--- {{{ astrocommunity
	{
		"AstroNvim/astrocommunity",
		lazy = false,
		{ import = "astrocommunity.docker.lazydocker" },
		{ import = "astrocommunity.scrolling.nvim-scrollbar" },
		{ import = "astrocommunity.git.diffview-nvim" },
		{ import = "astrocommunity.colorscheme.kanagawa-nvim" },
	},
	--- }}}

	--- {{{ disabling plugins and features
	{
		"rebelot/heirline.nvim",
		opts = function(_, opts)
			opts.winbar = nil
		end,
	},
	{
		"rcarriga/nvim-notify",
		enabled = false,
	},
	--- }}}
}
