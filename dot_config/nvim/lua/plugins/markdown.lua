--- @type LazySpec
return {
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      -- Note creation and management
      { "<leader>oo",  "<cmd>ObsidianNew<cr>",             desc = "Obsidian: Create a new note" },
      { "<leader>on",  "<cmd>ObsidianNewFromTemplate<cr>", desc = "Obsidian: New from template" },
      { "<leader>oe",  "<cmd>ObsidianExtractNote<cr>",     desc = "Obsidian: Extract note" },

      -- Navigation
      { "<leader>ow",  "<cmd>ObsidianSearch<cr>",          desc = "Obsidian: Search notes" },
      { "<leader>of",  "<cmd>ObsidianQuickSwitch<cr>",     desc = "Obsidian: Quick switch note" },
      { "<leader>ot",  "<cmd>ObsidianTags<cr>",            desc = "Obsidian: Search tags" },
      { "<leader>oW",  "<cmd>ObsidianWorkspace<cr>",       desc = "Obsidian: Switch workspace" },

      -- Daily notes
      { "<leader>od",  "<cmd>ObsidianToday<cr>",           desc = "Obsidian: Open today's note" },
      { "<leader>oy",  "<cmd>ObsidianYesterday<cr>",       desc = "Obsidian: Open yesterday's note" },
      { "<leader>or",  "<cmd>ObsidianTomorrow<cr>",        desc = "Obsidian: Open tomorrow's note" },
      { "<leader>oD",  "<cmd>ObsidianDailies<cr>",         desc = "Obsidian: List daily notes" },

      -- Links
      { "<leader>olc", "<cmd>ObsidianLink<cr>",            desc = "Obsidian: Create link" },
      { "<leader>oln", "<cmd>ObsidianLinkNew<cr>",         desc = "Obsidian: New note and link" },
      { "<leader>olb", "<cmd>ObsidianBacklinks<cr>",       desc = "Obsidian: Show backlinks" },
      { "<leader>olf", "<cmd>ObsidianFollowLink<cr>",      desc = "Obsidian: Follow link" },
      { "<leader>oll", "<cmd>ObsidianLinks<cr>",           desc = "Obsidian: Show all links" },

      -- insert
      { "<leader>oit", "<cmd>ObsidianTemplate<cr>",        desc = "Obsidian: Insert template" },
      { "<leader>oii", "<cmd>ObsidianPasteImg<cr>",        desc = "Obsidian: Paste image" },

      -- Utilities
      { "<leader>or",  "<cmd>ObsidianRename<cr>",          desc = "Obsidian: Rename note" },
      { "<leader>oT",  "<cmd>ObsidianTOC<cr>",             desc = "Obsidian: Table of Contents" },
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "work",
          path = "~/vaults/work",
        },
      },
    },
  },
  -- {
  --   "MeanderingProgrammer/render-markdown.nvim",
  --   cmd = "RenderMarkdown",
  --   ft = function()
  --     local plugin = require("lazy.core.config").spec.plugins["render-markdown.nvim"]
  --     local opts = require("lazy.core.plugin").values(plugin, "opts", false)
  --     return opts.file_types or { "markdown" }
  --   end,
  --   dependencies = {
  --     {
  --       "nvim-treesitter/nvim-treesitter",
  --       opts = function(_, opts)
  --         if opts.ensure_installed ~= "all" then
  --           opts.ensure_installed =
  --               require("utils").list_insert_unique(
  --                 opts.ensure_installed,
  --                 { "html", "markdown", "markdown_inline" }
  --               )
  --         end
  --       end,
  --     },
  --   },
  --   opts = {},
  -- },
  {
    "3rd/diagram.nvim",
    dependencies = {
      "3rd/image.nvim",
    },
    config = function()
      require("diagram").setup({
        integrations = {
          require("diagram.integrations.markdown"),
          require("diagram.integrations.neorg"),
        },
        renderer_options = {
          mermaid = {
            theme = "forest",
            scale = 2,
          },
          plantuml = {
            charset = "utf-8",
          },
          d2 = {
            theme_id = 1,
          },
          gnuplot = {
            theme = "dark",
            size = "800,600",
          },
        },
      })
    end,
  },
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    opts = {
      backend = "kitty",
      processor = "magick_cli", -- or "magick_cli"
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      kitty_method = "normal",
      hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp" }, -- render image files as images when opened
    },
  },
}
