return {
  'chomosuke/typst-preview.nvim',
  ft = 'typst',
  version = '1.*',
  config = function ()
    require("typst-preview").setup {
      open_cmd = 'firefox %s',
    }
  end
}
