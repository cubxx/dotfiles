return {
  'stevearc/conform.nvim',
  opts = {
    -- https://github.com/stevearc/conform.nvim/blob/master/lua/conform/formatters/
    formatters = {
      stylua = {
        append_args = {
          '--column-width',
          '120',
          '--indent-type',
          'spaces',
          '--indent-width',
          '2',
          '--quote-style',
          'AutoPreferSingle',
        },
      },
      prettier = {
        append_args = {
          '--single-quote',
          '--jsx-single-quote',
        },
      },
    },
    formatters_by_ft = {
      html = { 'prettier' },
      css = { 'prettier' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      markdown = { 'prettier' },
      lua = { 'stylua' },
      python = {},
      typst = {},
      rust = { 'rustfmt' },
    },
  },
}
