---@type LazySpec
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        hover = {
          enabled = false
        },
        signature = {
          enabled = false
        }
      }
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  },
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        "                                                     ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ",
        "                                                     ",
      }
      opts.section.buttons.val = {
        opts.button("e", "  > New file", ":ene <BAR> startinsert <CR>"),
        opts.button("f", "  > Find file", ":Telescope find_files<CR>"),
        opts.button("r", "  > Recent", ":Telescope oldfiles<CR>"),
        opts.button("s", "  > Sessions", ":lua require(\"resession\").load(nil, { dir = \"dirsession\" })<CR>"),
        opts.button("c", "  > Configs", ":e $MYVIMRC | :cd %:p:h | split . | wincmd k | pwd<CR>"),
      }
      return opts
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    config = function(_, opts)
      local cmp = require('cmp')

      local cmp_mappings = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
      });

      cmp_mappings['<Tab>'] = vim.NIL
      cmp_mappings['<S-Tab>'] = vim.NIL

      opts.mapping = cmp_mappings
      cmp.setup(opts)
    end
  },
  {
    "github/copilot.vim",
    event = "InsertEnter",
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
    end
  },
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(
        function(v) return not vim.tbl_contains({ "black", "isort" }, v) end,
        opts.ensure_installed
      )
    end,
  },
}
