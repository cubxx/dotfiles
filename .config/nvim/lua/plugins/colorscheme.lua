return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000,
  config = function()
    require('catppuccin').setup({
      flavour = 'mocha',
      transparent_background = true,
      default_integrations = false,
      auto_integrations = true,
      color_overrides = {
        all = {
          text = '#ffffff',
        },
        mocha = {
          base = '#000000',
          mantle = '#000000',
          crust = '#000000',
        },
      },
      lsp_styles = {
        inlay_hints = {
          background = false,
        },
      },
      custom_highlights = {
        LineNr = { fg = '#808080' },
      },
    })
    vim.cmd.colorscheme('catppuccin')
  end,
}
