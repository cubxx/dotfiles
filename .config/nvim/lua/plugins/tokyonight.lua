return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("tokyonight").setup {
      transparent= true,
    }
    vim.cmd.colorscheme("tokyonight")
    vim.api.nvim_set_hl(0, 'WinSeparator', { bg = 'NONE', fg = '#3b4261' })
  end,
}
