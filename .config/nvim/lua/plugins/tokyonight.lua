return {
  'folke/tokyonight.nvim',
  lazy = false,
  priority = 1000,
  config = function()
    require('tokyonight').setup({
      transparent = true,
    })
    vim.cmd.colorscheme('tokyonight')

    -- restore default
    for _, name in ipairs({
      'CursorLineNr',
      'LineNrAbove',
      'LineNrBelow',
      'FloatBorder',
    }) do
      vim.cmd('highlight clear ' .. name)
    end

    -- override
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#808080' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#000000' })
  end,
}
