local if_nil = vim.F.if_nil
local leader = "SPC"

local function button(sc, txt, keybind, keybind_opts)
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
    keybind_opts = if_nil(keybind_opts, { noremap = true, silent = true, nowait = true })
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

return {
  "goolord/alpha-nvim",
  opts = function(_, opts)
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
        button("f", "  Find file", ":Telescope find_files<CR>"),
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
        button(tostring(i), path, string.format(":lua require(\"resession\").load('%s', %s)<CR>", s, load_opts))
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
}
