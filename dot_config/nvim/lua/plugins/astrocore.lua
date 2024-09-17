-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- -- Configure core features of AstroNvim
    -- features = {
    --   large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
    --   autopairs = true, -- enable autopairs at start
    --   cmp = true, -- enable completion at start
    --   diagnostics_mode = 3, -- diagnostic mode on start (0 = off, 1 = no signs/virtual text, 2 = no virtual text, 3 = on)
    --   highlighturl = true, -- highlight URLs at start
    --   notifications = true, -- enable notifications at start
    -- },
    -- -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    -- diagnostics = {
    --   virtual_text = true,
    --   underline = true,
    -- },
    -- vim options can be configured here
    options = {
      -- opt = { -- vim.opt.<key>
      --   relativenumber = true, -- sets vim.opt.relativenumber
      --   number = true, -- sets vim.opt.number
      --   spell = false, -- sets vim.opt.spell
      --   signcolumn = "yes", -- sets vim.opt.signcolumn to yes
      --   wrap = false, -- sets vim.opt.wrap
      -- },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
        termguicolors = true,
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map
        ["<C-e>"] = { function() vim.cmd 'Neotree toggle' end },

        -- navigate buffer tabs
        ["<tab>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-tab>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<leader><space>"] = { function() require('telescope.builtin').find_files() end, desc = "find files" },

        -- toggle term
        ["<F12>"] = { "<Cmd> ToggleTerm direction=horizontal size=25 <CR>", desc = "Toggle term horizontal" },
        ["2<F12>"] = { "<Cmd> 2ToggleTerm direction=horizontal size=25 <CR>", desc = "Toggle term horizontal" },

        ["<leader>tt"] = { "<Cmd> ToggleTerm direction=float <CR>", desc = "Toggle Term float" },
        ["<leader>t-"] = { "<Cmd> ToggleTerm direction=horizontal size=25 <CR>", desc = "Toggle Term float" },
        ["<leader>t|"] = { "<Cmd> ToggleTerm direction=vertical size=60 <CR>", desc = "Toggle Term float" },

        ["<leader>2tt"] = { "<Cmd> 2ToggleTerm direction=float <CR>", desc = "Toggle Term float" },
        ["<leader>2t-"] = { "<Cmd> 2ToggleTerm direction=horizontal size=25 <CR>", desc = "Toggle Term float" },
        ["<leader>2t|"] = { "<Cmd> 2ToggleTerm direction=vertical size=60 <CR>", desc = "Toggle Term float" },
      },
      t = {
        ["<C-[>"] = { "<C-\\><C-n>", desc = "to normal mode" },
        ["<F12>"] = { "<Cmd> ToggleTerm <CR>", desc = "close term" },
        ["2<F12>"] = { "<Cmd> 2ToggleTerm <CR>", desc = "close term" },
      }
    },
  },
}
