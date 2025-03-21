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
        { "<c-h>", "<cmd>ZellijNavigateLeftTab<cr>",  desc = "navigate left or tab",  mode = "n" },
        { "<c-j>", "<cmd>ZellijNavigateDown<cr>",     desc = "navigate down",         mode = "n" },
        { "<c-k>", "<cmd>ZellijNavigateUp<cr>",       desc = "navigate up",           mode = "n" },
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
        { "<C-h>",  "<cmd>TmuxNavigateLeft<cr>",                desc = "navigate left",     mode = "n" },
        { "<C-j>",  "<cmd>TmuxNavigateDown<cr>",                desc = "navigate down",     mode = "n" },
        { "<C-k>",  "<cmd>TmuxNavigateUp<cr>",                  desc = "navigate up",       mode = "n" },
        { "<C-l>",  "<cmd>TmuxNavigateRight<cr>",               desc = "navigate right",    mode = "n" },
        { "<C-\\>", "<cmd>TmuxNavigatePrevious<cr>",            desc = "navigate previous", mode = "n" },
        -- terminal
        { "<C-h>",  "<C-\\><C-N><cmd>TmuxNavigateLeft<cr>",     desc = "navigate left",     mode = "t" },
        { "<C-j>",  "<C-\\><C-N><cmd>TmuxNavigateDown<cr>",     desc = "navigate down",     mode = "t" },
        { "<C-k>",  "<C-\\><C-N><cmd>TmuxNavigateUp<cr>",       desc = "navigate up",       mode = "t" },
        { "<C-l>",  "<C-\\><C-N><cmd>TmuxNavigateRight<cr>",    desc = "navigate right",    mode = "t" },
        { "<C-\\>", "<C-\\><C-N><cmd>TmuxNavigatePrevious<cr>", desc = "navigate previous", mode = "t" },
      },
    }
  end
end)() -- }}}

--- @type LazySpec
return {
  --- {{{ comform
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        -- css = { "prettier" },
        -- html = { "prettier" },
      },

      format_on_save = {
        -- These options will be passed to conform.format()
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },
  --- }}}

  --- {{{ lsp
  {
    "folke/neoconf.nvim",
    config = function()
      require("neoconf").setup {}
      require("nvchad.configs.lspconfig").defaults()
    end,
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = {
      ensure_installed = { "lua_ls" }
    }
  },
  --- }}}

  --- {{{ treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "json",
        "yaml",
        "toml",
        "bash",
        "python",
        "rust",
        "go",
      },
    },
  },
  --- }}}

  --- {{{ neovim-session-manager
  {
    "Shatur/neovim-session-manager",
    cmd = {
      "SessionManager",
    },
    keys = {
      {
        "<leader>ss",
        "<cmd>SessionManager save_current_session<CR>",
        desc = "Save Session",
      },
      {
        "<leader>sl",
        "<cmd>SessionManager load_session<CR>",
        desc = "Load Session",
      },
      {
        "<leader>sL",
        "<cmd>SessionManager load_last_session<CR>",
        desc = "Load Last Session",
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  --- }}}

  --- {{{ snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      picker = { layout = "default" },
      image = { enabled = true },
      scroll = {
        animate = {
          duration = { step = 5, total = 50 },
          easing = "linear",
        },
      },
      words = { enabled = true },
    },
    keys = {
      { "<leader>..", function() require("snacks").scratch() end,        desc = "Toggle Scratch Buffer" },
      { "<leader>.S", function() require("snacks").scratch.select() end, desc = "Select Scratch Buffer" },
    },
  },
  --- }}}

  --- {{{ cmp and copilot
  {
    "hrsh7th/nvim-cmp",
    config = function(_, opts)
      local cmp = require "cmp"

      local cmp_mappings = cmp.mapping.preset.insert {
        ["<CR>"] = cmp.mapping.confirm { select = false },
      }

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

  --- {{{ nvim-tree
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      local function my_on_attach(bufnr)
        local api = require "nvim-tree.api"

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.del("n", "<C-e>", { buffer = bufnr })
        vim.keymap.set("n", "l", api.node.open.edit, opts "Open")
      end

      return {
        on_attach = my_on_attach,
        filters = { dotfiles = false },
        disable_netrw = true,
        hijack_cursor = true,
        sync_root_with_cwd = true,
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          width = 30,
          preserve_window_proportions = true,
        },
        renderer = {
          root_folder_label = ":~:s?$?/?",
          highlight_git = true,
          indent_markers = { enable = true },
          icons = {
            glyphs = {
              default = "󰈚",
              folder = {
                default = "",
                empty = "",
                empty_open = "",
                open = "",
                symlink = "",
              },
              git = { unmerged = "" },
            },
          },
        },
      }
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
      { "<leader>ac", "<cmd>CopilotChat<cr>", { silent = true, desc = "Open Copilot Chat" } },
    },
    config = function()
      -- Disable the enable_claude function
      local Copilot = require "CopilotChat.copilot"
      Copilot.enable_claude = function() end

      require("CopilotChat").setup {
        model = "claude-3.7-sonnet",
        context = "buffer",
        show_help = false,
        window = {
          layout = "vertical",
          width = 74,               -- absolute width in columns
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
      }
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
      { "<leader>ai", "<cmd>AiderTerminalToggle<cr>",    desc = "Open Aider" },
      { "<leader>as", "<cmd>AiderTerminalSend<cr>",      desc = "Send to Aider",                  mode = { "n", "v" } },
      { "<leader>ac", "<cmd>AiderQuickSendCommand<cr>",  desc = "Send Command To Aider" },
      { "<leader>ab", "<cmd>AiderQuickSendBuffer<cr>",   desc = "Send Buffer To Aider" },
      { "<leader>a+", "<cmd>AiderQuickAddFile<cr>",      desc = "Add File to Aider" },
      { "<leader>a-", "<cmd>AiderQuickDropFile<cr>",     desc = "Drop File from Aider" },
      { "<leader>ar", "<cmd>AiderQuickReadOnlyFile<cr>", desc = "Add File as Read-Only" },
      -- Example nvim-tree.lua integration if needed
      { "<leader>a+", "<cmd>AiderTreeAddFile<cr>",       desc = "Add File from Tree to Aider",    ft = "NvimTree" },
      { "<leader>a-", "<cmd>AiderTreeDropFile<cr>",      desc = "Drop File from Tree from Aider", ft = "NvimTree" },
    },
    dependencies = {
      "folke/snacks.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    config = true,
    opts = {
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
        enabled = true,         -- enables the Noice cmdline UI
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
        bottom_search = false,         -- use a classic bottom cmdline for search
        command_palette = false,       -- position the cmdline and popupmenu together
        long_message_to_split = false, -- long messages will be sent to a split
        inc_rename = false,            -- enables an input dialog for inc-rename.nvim
        lsp_doc_border = false,        -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  --- }}}

  window_move_plugin,
}
