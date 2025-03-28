-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "typescript",
      "javascript",
      "json",
      "yaml",
      "html",
      "css",
      "bash",
      "python",
      "rust",
      "toml",
      "markdown",
      "markdown_inline",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
