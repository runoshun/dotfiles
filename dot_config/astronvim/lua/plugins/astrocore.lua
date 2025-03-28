-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local MyTerminal = require("utils.my_toggle_terminal")
_G.my_rightbelow_terminal = MyTerminal:new(15, "belowright")

local function clipboard_option()
  if os.getenv("SSH_CONNECTION") ~= nil then
    local function paste()
      return {
        vim.fn.split(vim.fn.getreg(""), "\n"),
        vim.fn.getregtype(""),
      }
    end
    return {
      name = "OSC 52",
      copy = {
        ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
        ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
      },
      paste = {
        ["+"] = paste,
        ["*"] = paste,
      },
    }
  else
    return nil
  end
end

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
      opt = {
        relativenumber = false,
        clipboard = "unnamedplus",
        foldcolumn = "0",
      },
      g = { -- vim.g.<key>
        termguicolors = true,
        clipboard = clipboard_option(),
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        ["<C-e>"] = { function() vim.cmd 'Neotree toggle' end },
        [";"] = { ":" },

        ["<tab>"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["<S-tab>"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        ["<leader><space>"] = { function() require('telescope.builtin').find_files() end, desc = "find files" },
        ["<F12>"] = { function() _G.my_rightbelow_terminal:toggle() end, desc = "Toggle Right Below Terminal" },
        ["<leader>aP"] = { function() require("utils.copilot_server").restart() end, desc = "Restart Copilot Proxy" },
      },
      t = {
        ["<C-]>"] = { "<C-\\><C-n>", desc = "to normal mode" },
      }
    },
  },
}
