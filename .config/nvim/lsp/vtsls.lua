return {
  init_options = { hostInfo = 'neovim' },
  cmd = { 'vtsls', '--stdio' },
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      { 'package-lock.json', 'yarn.lock', 'pnpm-lock.yaml', 'bun.lockb', 'bun.lock' },
      { 'node_modules', '.git' },
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
  -- https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json
}
