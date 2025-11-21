return {
  {
    'nvim-mini/mini.icons',
    version = '*',
    opts = {
      style = 'glyph',
      file = {
        ['.gitconfig'] = { glyph = '󰊢', hl = 'MiniIconsPurple' },
      },
    },
    config = function(_, opts)
      local icons = require('mini.icons')
      icons.setup(opts)
      vim.schedule(icons.tweak_lsp_kind)
    end,
  },
  {
    'nvim-mini/mini.surround',
    version = '*',
    opts = {
      mappings = {
        add = 'sa', -- Add surrounding in Normal and Visual modes
        delete = 'sd', -- Delete surrounding
        find = 'sf', -- Find surrounding (to the right)
        find_left = 'sF', -- Find surrounding (to the left)
        highlight = 'sh', -- Highlight surrounding
        replace = 'sr', -- Replace surrounding
        update_n_lines = 'sn', -- Update `n_lines`

        suffix_last = 'l', -- Suffix to search with "prev" method
        suffix_next = 'n', -- Suffix to search with "next" method
      },
    },
  },
  {
    'nvim-mini/mini.indentscope',
    enabled = false,
    version = '*',
    config = function()
      local mod = require('mini.indentscope')
      mod.setup({ draw = { animation = mod.gen_animation.none() } })
      vim.api.nvim_set_hl(0, 'MiniIndentscopeSymbol', { fg = '#808080' })
    end,
  },
}
