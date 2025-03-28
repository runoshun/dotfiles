local utils = require "utils"

return {
  {
    "williamboman/mason.nvim",
  },
  {
    "b0o/schemastore.nvim",
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    opts = function(_, opts)
      opts.ensure_installed = utils.list_insert_unique(opts.ensure_installed, { "jsonls", "yamlls" })

      opts.handlers = opts.handlers or {}
      opts.handlers["jsonls"] = function(servername)
        --Enable (broadcasting) snippet capability for completion
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true

        require("lspconfig")[servername].setup {
          capabilities = capabilities,
          filetypes = { "json", "jsonc" },
          settings = {
            json = {
              schemas = require("schemastore").json.schemas(),
              validate = { enable = true },
            },
          },
        }
      end

      opts.handlers["yamlls"] = function(servername)
        --Enable (broadcasting) snippet capability for completion
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities.textDocument.completion.completionItem.snippetSupport = true

        require("lspconfig")[servername].setup {

          capabilities = capabilities,
          settings = {
            yaml = {
              schemaStore = {
                -- You must disable built-in schemaStore support if you want to use
                -- this plugin and its advanced options like `ignore`.
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
              schemas = require("schemastore").yaml.schemas(),
            },
          },
        }
      end

      return opts
    end,
  },
}
