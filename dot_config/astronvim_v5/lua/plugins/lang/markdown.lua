--- @type LazySpec
return {
  {
    "zk-org/zk-nvim",
    event = "VeryLazy",
    config = function()
      require("zk").setup({
        picker = "snacks_picker",
      })
    end,
    keys = {
      -- Open the link under the caret
      {
        "<CR>",
        "<cmd>lua vim.lsp.buf.definition()<cr>",
        mode = "n",
        desc = "Open link under cursor",
        ft = { "markdown" },
      },

      -- Note creation
      {
        "<leader>znn",
        function()
          require("zk").new({
            dir = vim.fn.expand("%:p:h"),
            title = vim.fn.input("Title: "),
          })
        end,
        mode = "n",
        desc = "Create new note",
        ft = { "markdown" },
      },
      {
        "<leader>znt",
        ":'<,'>ZkNewFromTitleSelection { dir = vim.fn.expand('%:p:h') }<cr>",
        mode = "v",
        desc = "Create note from selection (title)",
        ft = { "markdown" },
      },
      {
        "<leader>znc",
        ":'<,'>ZkNewFromContentSelection { dir = vim.fn.expand('%:p:h'), title = vim.fn.input('Title: ') }<cr>",
        mode = "v",
        desc = "Create note from selection (content)",
        ft = { "markdown" },
      },

      -- Backlinks and navigation
      {
        "<leader>zb",
        "<cmd>ZkBacklinks<cr>",
        mode = "n",
        desc = "Show backlinks",
        ft = { "markdown" },
      },
      {
        "<leader>zl",
        "<cmd>ZkLinks<cr>",
        mode = "n",
        desc = "Show linked notes",
        ft = { "markdown" },
      },

      -- Preview and actions
      {
        "K",
        "<cmd>lua vim.lsp.buf.hover()<cr>",
        mode = "n",
        desc = "Preview linked note",
        ft = { "markdown" },
      },
      {
        "<leader>za",
        ":'<,'>lua vim.lsp.buf.range_code_action()<cr>",
        mode = "v",
        desc = "Code actions",
        ft = { "markdown" },
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    config = function()
      vim.api.nvim_set_hl(0, "RenderMarkdownH1", { link = "St_ReplaceMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2", { link = "St_TerminalMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3", { link = "St_ConfirmMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4", { link = "St_NTerminalMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5", { link = "St_InsertMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6", { link = "St_SelectMode" })

      vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { link = "St_ReplaceMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { link = "St_TerminalMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { link = "St_ConfirmMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { link = "St_NTerminalMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { link = "St_InsertMode" })
      vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { link = "St_SelectMode" })
      require("render-markdown").setup({})
    end,
  },
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
