return {
  {
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    version = '^1',
    config = function()
      require('blink.cmp').setup({
        keymap = {
          preset = 'none',
          ['<Esc>'] = { 'hide', 'fallback' },
          ['<Tab>'] = { 'select_and_accept', 'fallback' },
          ['<Up>'] = { 'select_prev', 'fallback' },
          ['<Down>'] = { 'select_next', 'fallback' },
          ['<PageUp>'] = { 'scroll_documentation_up', 'fallback' },
          ['<PageDown>'] = { 'scroll_documentation_down', 'fallback' },
        },
        completion = {
          documentation = { auto_show = true },
          list = { selection = { auto_insert = false } },
          menu = { draw = { treesitter = { 'lsp' } } },
        },
        signature = { enabled = true },
        cmdline = {
          keymap = { preset = 'inherit' },
          completion = { menu = { auto_show = true } },
        },
      })
    end,
  },
  {
    'm4xshen/autoclose.nvim',
    event = { 'InsertEnter', 'CmdlineEnter' },
    opts = {
      options = {
        pair_spaces = true,
      },
    },
  },
}
