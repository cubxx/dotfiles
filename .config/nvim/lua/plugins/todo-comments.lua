return {
  'folke/todo-comments.nvim',
  event = 'LazyFile',
  opts = {
    signs = false,
  },
  keys = {
    {
      ']t',
      function()
        require('todo-comments').jump_next()
      end,
      desc = 'Next Todo Comment',
    },
    {
      '[t',
      function()
        require('todo-comments').jump_prev()
      end,
      desc = 'Previous Todo Comment',
    },
  },
}
