---@type vim.lsp.Config
return {
  cmd = { 'tinymist' }, -- installed by typst-preview
  filetypes = { 'typst' },
  root_markers = { '.git' },
  settings = {
    formatterMode = 'typstyle',
    lint = {
      enabled = true,
    },
    preview = {
      refresh = 'onSave',
    },
  },
}
