return {
  {
    'nvim-treesitter/nvim-treesitter-context',
  },
  {
    'romus204/tree-sitter-manager.nvim',
    config = function()
      require('tree-sitter-manager').setup({
        assume_installed = { 'lua', 'c', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      })
    end,
  },
}
