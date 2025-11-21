return {
  'stevearc/conform.nvim',
  opts = {
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
    },
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff' },
      javascript = { 'prettier' },
      typescript = { 'prettier' },
      json = { 'prettier' },
      markdown = { 'prettier' },
      typst = {},
    },
    format_on_save = { lsp_format = 'fallback' },
  },
}
