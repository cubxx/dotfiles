return {
  "nvim-treesitter/nvim-treesitter",
  branch = 'main',
  build = ":TSUpdate",
  event = { "LazyFile", "VeryLazy" },
  config = function()
    require('nvim-treesitter').setup {
      ensure_installed = {
        "lua", "bash", "nginx", "sql", "awk", "regex",
        "markdown", "markdown_inline", "typst",
        "html", "css", "javascript", "jsdoc", "typescript", "tsx",
        "yaml", "json", "csv",
        "python", "rst", "go",
      },
      auto_install = true,
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      folds = { enable = true },
    }
  end,
}
