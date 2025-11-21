---@type vim.lsp.Config
return {
  cmd = { 'tinymist' }, -- installed by typst-preview
  filetypes = { 'typst' },
  root_markers = { '.git' },
  -- https://myriad-dreamin.github.io/tinymist/config/neovim.html
  settings = {
    lint = {
      enabled = true,
    },
    preview = {
      refresh = 'onSave',
    },
  },
}
