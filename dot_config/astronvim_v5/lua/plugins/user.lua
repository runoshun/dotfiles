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

	--- {{{ cmp and copilot
	{
		"saghen/blink.cmp",
		build = "cargo build --release",
		opts = {
			keymap = {
				preset = "default",
				["<Tab>"] = {},
				["<C-J>"] = {},
			},
		},
	},
	-- {
	-- 	"github/copilot.vim",
	-- 	event = "BufEnter",
	-- 	config = function()
	-- 		vim.g.copilot_filetypes = {
	-- 			yaml = true,
	-- 			bash = true,
	-- 			python = true,
	-- 			markdown = true,
	-- 			typescript = true,
	-- 			javascript = true,
	-- 			lua = true,
	-- 		}
	-- 		vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
	-- 			expr = true,
	-- 			replace_keycodes = false,
	-- 		})
	-- 	end,
	-- },
	{
		"zbirenbaum/copilot.lua",
		opts = {
			panel = {
				enabled = false,
			},
			suggestion = {
				auto_trigger = true,
				keymap = {
					accept = "<Tab>",
					accept_word = false,
					accept_line = false,
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
			},
			filetypes = {
				yaml = true,
				bash = true,
				python = true,
				markdown = true,
				typescript = true,
				javascript = true,
				lua = true,
			},
			copilot_model = "gpt-4o-copilot",
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
			opts.words = { enabled = true }

			local sess = require("resession").list({ dir = "dirsession" })
			local sessions = {}
			for i, s in ipairs(sess) do
				if i > 5 then
					break
				end

				local path = s:gsub("_", "/")
				path = path:gsub("^" .. os.getenv("HOME"), "~")
				path = path:len() > 40 and path:sub(1, 20) .. "..." .. path:sub(-20) or path

				local load_opts = '{ dir = "dirsession", attach = true, reset = "auto" }'
				table.insert(sessions, {
					key = tostring(i),
					action = string.format("<cmd>lua require(\"resession\").load('%s', %s)<CR>", s, load_opts),
					icon = tostring(i),
					desc = "Load Session " .. path,
				})
			end
			local keys = {
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
			}
			for i, k in ipairs(keys) do
				table.insert(sessions, k)
			end

			opts.dashboard = {
				preset = {
					keys = sessions,
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
					-- { source = "document_symbols" },
					-- { source = "git_status" },
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

	--- {{{ namu.nvim
	{
		"bassamsdata/namu.nvim",
		config = function()
			require("namu").setup({
				namu_symbols = {
					enable = true,
					options = {}, -- here you can configure namu
				},
				ui_select = { enable = false }, -- vim.ui.select() wrapper
				colorscheme = {
					enable = false,
					options = {
						persist = true, -- very efficient mechanism to Remember selected colorscheme
						write_shada = false, -- If you open multiple nvim instances, then probably you need to enable this
					},
				},
			})
			-- === Suggested Keymaps: ===
			vim.keymap.set("n", "<leader>ss", ":Namu symbols<cr>", {
				desc = "Jump to LSP symbol",
				silent = true,
			})
			vim.keymap.set("n", "<leader>th", ":Namu colorscheme<cr>", {
				desc = "Colorscheme Picker",
				silent = true,
			})
		end,
	},
	--- }}}

	--- {{{ astrocommunity
	{
		"AstroNvim/astrocommunity",
		lazy = false,
		{ import = "astrocommunity.git.diffview-nvim" },
		{ import = "astrocommunity.scrolling.nvim-scrollbar" },
		{ import = "astrocommunity.colorscheme.kanagawa-nvim" },

		{ import = "astrocommunity.recipes.picker-nvchad-theme" },
	},
	--- }}}

	--- {{{ disabling plugins and features
	{
		"rebelot/heirline.nvim",
		opts = function(_, opts)
			opts.winbar = nil
		end,
	},
	--- }}}

	--- {{{ heirline nvchad from astrocommunity
	{
		"AstroNvim/astroui",
		---@type AstroUIOpts
		opts = {
			-- add new user interface icon
			icons = {
				VimIcon = "",
				ScrollText = "",
				GitBranch = "",
				GitAdd = "",
				GitChange = "",
				GitDelete = "",
			},
			-- modify variables used by heirline but not defined in the setup call directly
			status = {
				-- define the separators between each section
				separators = {
					left = { "", "" }, -- separator for the left side of the statusline
					right = { "▐", "" }, -- separator for the right side of the statusline
					tab = { "", "" },
				},
				-- add new colors that can be used by heirline
				colors = function(hl)
					local get_hlgroup = require("astroui").get_hlgroup
					-- use helper function to get highlight group properties
					local comment_fg = get_hlgroup("Comment").fg
					hl.git_branch_fg = comment_fg
					hl.git_added = comment_fg
					hl.git_changed = comment_fg
					hl.git_removed = comment_fg
					hl.blank_bg = get_hlgroup("Folded").fg
					hl.file_info_bg = get_hlgroup("Visual").bg
					hl.nav_icon_bg = get_hlgroup("String").fg
					hl.nav_fg = hl.nav_icon_bg
					hl.folder_icon_bg = get_hlgroup("Function").fg
					return hl
				end,
				attributes = {
					mode = { bold = true },
				},
				icon_highlights = {
					file_icon = {
						statusline = false,
					},
				},
			},
		},
	},
	{
		"rebelot/heirline.nvim",
		opts = function(_, opts)
			local status = require("astroui.status")
			opts.statusline = {
				-- default highlight for the entire statusline
				hl = { fg = "fg", bg = "bg" },
				-- each element following is a component in astroui.status module

				-- add the vim mode component
				status.component.mode({
					-- enable mode text with padding as well as an icon before it
					mode_text = {
						icon = { kind = "VimIcon", padding = { right = 1, left = 1 } },
					},
					-- surround the component with a separators
					surround = {
						-- it's a left element, so use the left separator
						separator = "left",
						-- set the color of the surrounding based on the current mode using astronvim.utils.status module
						color = function()
							return { main = status.hl.mode_bg(), right = "blank_bg" }
						end,
					},
				}),
				-- we want an empty space here so we can use the component builder to make a new section with just an empty string
				status.component.builder({
					{ provider = "" },
					-- define the surrounding separator and colors to be used inside of the component
					-- and the color to the right of the separated out section
					surround = {
						separator = "left",
						color = { main = "blank_bg", right = "file_info_bg" },
					},
				}),
				-- add a section for the currently opened file information
				status.component.file_info({
					-- enable the file_icon and disable the highlighting based on filetype
					filename = { fallback = "Empty" },
					-- disable some of the info
					filetype = false,
					file_read_only = false,
					-- add padding
					padding = { right = 1 },
					-- define the section separator
					surround = { separator = "left", condition = false },
				}),
				-- add a component for the current git branch if it exists and use no separator for the sections
				status.component.git_branch({
					git_branch = { padding = { left = 1 } },
					surround = { separator = "none" },
				}),
				-- add a component for the current git diff if it exists and use no separator for the sections
				status.component.git_diff({
					padding = { left = 1 },
					surround = { separator = "none" },
				}),
				-- fill the rest of the statusline
				-- the elements after this will appear in the middle of the statusline
				status.component.fill(),
				-- add a component to display if the LSP is loading, disable showing running client names, and use no separator
				status.component.lsp({
					lsp_client_names = false,
					surround = { separator = "none", color = "bg" },
				}),
				-- fill the rest of the statusline
				-- the elements after this will appear on the right of the statusline
				status.component.fill(),
				-- add a component for the current diagnostics if it exists and use the right separator for the section
				status.component.diagnostics({ surround = { separator = "right" }, padding = { right = 1 } }),
				-- add a component to display LSP clients, disable showing LSP progress, and use the right separator
				status.component.lsp({
					lsp_progress = false,
					padding = { right = 1 },
					surround = { separator = "right" },
				}),
				-- NvChad has some nice icons to go along with information, so we can create a parent component to do this
				-- all of the children of this table will be treated together as a single component
				{
					flexible = 1,
					{
						-- define a simple component where the provider is just a folder icon
						status.component.builder({
							-- astronvim.get_icon gets the user interface icon for a closed folder with a space after it
							{ provider = require("astroui").get_icon("FolderClosed") },
							-- add padding after icon
							padding = { right = 1 },
							-- set the foreground color to be used for the icon
							hl = { fg = "bg" },
							-- use the right separator and define the background color
							surround = { separator = "right", color = "folder_icon_bg" },
						}),
						-- add a file information component and only show the current working directory name
						status.component.file_info({
							-- we only want filename to be used and we can change the fname
							-- function to get the current working directory name
							filename = {
								fname = function(nr)
									return vim.fn.getcwd(nr)
								end,
								padding = { left = 1, right = 1 },
							},
							-- disable all other elements of the file_info component
							filetype = false,
							file_icon = false,
							file_modified = false,
							file_read_only = false,
							-- use no separator for this part but define a background color
							surround = {
								separator = "none",
								color = "file_info_bg",
								condition = false,
							},
						}),
					},
					{},
				},
				-- the final component of the NvChad statusline is the navigation section
				-- this is very similar to the previous current working directory section with the icon
				{ -- make nav section with icon border
					-- define a custom component with just a file icon
					status.component.builder({
						{ provider = require("astroui").get_icon("ScrollText") },
						-- add padding after icon
						padding = { right = 1 },
						-- set the icon foreground
						hl = { fg = "bg" },
						-- use the right separator and define the background color
						-- as well as the color to the left of the separator
						surround = {
							separator = "right",
							color = { main = "nav_icon_bg", left = "file_info_bg" },
						},
					}),
					-- add a navigation component and just display the percentage of progress in the file
					status.component.nav({
						-- add some padding for the percentage provider
						percentage = { padding = { right = 1 } },
						-- disable all other providers
						ruler = false,
						scrollbar = false,
						-- use no separator and define the background color
						surround = { separator = "none", color = "file_info_bg" },
					}),
				},
			}
		end,
	},
	--- }}}
}
