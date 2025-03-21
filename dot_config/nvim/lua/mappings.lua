local map = vim.keymap.set

local tabufline = function() return require "nvchad.tabufline" end
local term = function() return require "nvchad.term" end
local gitsigns = function() return require "gitsigns" end
local snacks = function() return require "snacks" end

-- elementary operations -------------------------------------------------------
map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<C-e>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })
map("n", "<C-s>", "<cmd>w<CR>", { desc = "general save file" })

map("n", "<tab>", function() tabufline().next() end, { desc = "buffer goto next" })
map("n", "<S-tab>", function() tabufline().prev() end, { desc = "buffer goto prev" })

map("n", "<leader>c", function() tabufline().close_buffer() end, { desc = "buffer close" })
map("n", "<leader>Q", function() vim.cmd "qa" end, { desc = "buffer close" })

map("n", "<leader>/", "gcc", { desc = "toggle comment", remap = true })
map("v", "<leader>/", "gc", { desc = "toggle comment", remap = true })

map({ "n", "t" }, "<F12>", function() term().toggle { pos = "sp", id = "main" } end, { desc = "Toggle Terminal" })

-- nv -- nvchad mappings -------------------------------------------------------
map("n", "<leader>nvch", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })
map("n", "<leader>nvth", function() require("nvchad.themes").open() end, { desc = "telescope nvchad themes" })

-- l -- lsp mappings -----------------------------------------------------------
map("n", "<leader>la", vim.lsp.buf.code_action, { desc = "LSP code action" })
map("n", "<leader>li", vim.lsp.buf.incoming_calls, { desc = "LSP definition" })
map("n", "<leader>lr", function() require "nvchad.lsp.renamer"() end, { desc = "LSP rename" })
map("n", "<leader>lR", function() snacks().picker.lsp_references() end, { desc = "LSP references" })
map("n", "<leader>lc", function() snacks().picker.lsp_config() end, { desc = "LSP find config" })
map("n", "<leader>ls", function() snacks().picker.lsp_workspace_symbols() end, { desc = "LSP find symbols" })
map("n", "<leader>lD", function() snacks().picker.lsp_difinitions() end, { desc = "LSP find difinitions" })
map("n", "<leader>ls", function() snacks().picker.lsp_declaration() end, { desc = "LSP find declaration" })
map("n", "<leader>lt", function() snacks().picker.lsp_type_definitions() end, { desc = "LSP find type definitions" })

-- b -- buffer mappings --------------------------------------------------------
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "buffer new" })
map("n", "<leader>bc", function() tabufline().closeAllBufs(false) end, { desc = "buffer close others" })
map("n", "<leader>bc", function() tabufline().closeAllBufs(true) end, { desc = "buffer close all" })
map(
  "n",
  "<leader>bf",
  function() require("conform").format { lsp_fallback = true } end,
  { desc = "general format file" }
)

-- f -- fizzy finder mappings ------------------------------------
map("n", "<leader>ff", function() snacks().picker.smart() end, { desc = "find files, buffer, recent" })
map("n", "<leader>fF", function() snacks().picker.files { hidden = true } end, { desc = "find files" })
map("n", "<leader>fp", function() snacks().picker.pickers() end, { desc = "find pickers" })
map("n", "<leader>fc", function() snacks().picker.command_history() end, { desc = "find command_history" })

map("n", "<leader>fw", function() snacks().picker.grep() end, { desc = "live grep" })
map("n", "<leader>fh", function() snacks().picker.help() end, { desc = "find help" })
map("n", "<leader>fu", function() snacks().picker.undo() end, { desc = "find undo histry" })

-- g -- git related mappings -----------------------------------------------------
map("n", "<leader>gg", function() snacks().lazygit() end, { desc = "lazygit" })

map("n", "<leader>gl", function() gitsigns().blame_line() end, { desc = "View Git blame" })
map("n", "<leader>gL", function() gitsigns().blame_line { full = true } end, { desc = "View full Git blame" })
map("n", "<leader>gp", function() gitsigns().preview_hunk_inline() end, { desc = "Preview Git hunk" })
map("n", "<leader>gr", function() gitsigns().reset_hunk() end, { desc = "Reset Git hunk" })
map(
  "v",
  "<leader>gr",
  function() gitsigns().reset_hunk { vim.fn.line ".", vim.fn.line "v" } end,
  { desc = "Reset Git hunk" }
)
map("n", "<leader>gR", function() gitsigns().reset_buffer() end, { desc = "Reset Git buffer" })
map("n", "<leader>gs", function() gitsigns().stage_hunk() end, { desc = "Stage Git hunk" })
map(
  "v",
  "<leader>gs",
  function() gitsigns().stage_hunk { vim.fn.line ".", vim.fn.line "v" } end,
  { desc = "Stage Git hunk" }
)
map("n", "<leader>gS", function() gitsigns().stage_buffer() end, { desc = "Stage Git buffer" })
map("n", "<leader>gu", function() gitsigns().undo_stage_hunk() end, { desc = "Unstage Git hunk" })
map("n", "<leader>gd", function() gitsigns().diffthis() end, { desc = "View Git diff" })

-- nt -- notifiers mappings -----------------------------------------------------
map("n", "<leader>nth", function() snacks().notifier.show_history() end, { desc = "show notification history" })
map("n", "<leader>ntd", function() snacks().notifier.hide() end, { desc = "hide notification" })

-- t -- terminal mappings ------------------------------------------------------
map("n", "<leader>tf", function() term().toggle { pos = "float" } end, { desc = "floating terminal" })

-- ================================================================
-- terminal mode mappings
-- ================================================================
map("t", "<C-[>", "<C-\\><C-N>", { desc = "terminal escape terminal mode" })
