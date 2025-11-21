return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'master',
  lazy = false,
  build = ':TSUpdate',
  dependencies = {
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      branch = 'master',
    },
    {
      'nvim-treesitter/nvim-treesitter-context',
    },
  },
  config = function()
    require('nvim-treesitter.configs').setup({
     -- stylua: ignore
      auto_install = true,
      ignore_install = {},
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      folds = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
      },
    })
  end,
}
