-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

local bg_float2 = "#14151f"
local bg_float3 = "#0a0b10"

M.base46 = {
  theme = "kanagawa",
  hl_add = {
    SnacksPicker = { fg = "fg", bg = bg_float2 },
    SnacksPickerTitle = { fg = bg_float2, bg = "blue" },
    SnacksPickerBorder = { fg = bg_float2, bg = bg_float2 },
    SnacksPickerInput = { fg = "fg", bg = "bg_float" },
    SnacksPickerInputTitle = { fg = "bg_float", bg = "orange" },
    SnacksPickerInputBorder = { fg = "bg_float", bg = "bg_float" },
    SnacksPickerPreview = { fg = "fg", bg = bg_float3 },
    SnacksPickerPreviewBorder = { fg = bg_float3, bg = bg_float3 },
  },
}
M.lsp = {
  signature = true,
}

M.nvdash = {
  load_on_startup = true,

  header = {
    "                            ",
    "     ▄▄         ▄ ▄▄▄▄▄▄▄   ",
    "   ▄▀███▄     ▄██ █████▀    ",
    "   ██▄▀███▄   ███           ",
    "   ███  ▀███▄ ███           ",
    "   ███    ▀██ ███           ",
    "   ███      ▀ ███           ",
    "   ▀██ █████▄▀█▀▄██████▄    ",
    "     ▀ ▀▀▀▀▀▀▀ ▀▀▀▀▀▀▀▀▀▀   ",
    "                            ",
    "     Powered By  eovim    ",
    "                            ",
  },

  buttons = {
    { txt = "  Restore Session", keys = "Spc s L", cmd = "SessionManager load_last_session" },
    { txt = "  Load Session", keys = "Spc s L", cmd = "SessionManager load_session" },
    { txt = "  New File", keys = "Spc b n", cmd = "ene | startinsert" },
    { txt = "  Find File", keys = "Spc f f", cmd = "lua Snacks.picker.smart()" },
    { txt = "  Quit", keys = "Spc Q", cmd = "qa" },
  },
}
M.ui = {
  tabufline = {
    lazyload = false,
  },
}

return M
