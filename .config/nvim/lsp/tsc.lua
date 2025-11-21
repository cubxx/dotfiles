---@type vim.lsp.Config
return {
  init_options = { hostInfo = 'neovim' },
  cmd = function(dispatchers, config)
    local root_dir = config.root_dir
    local cmd = vim.fs.joinpath(root_dir, 'node_modules/.bin', 'tsc')
    if vim.fn.executable(cmd) == 1 then
      local version = vim.fn.system({ cmd, '--version' })
      if version:find('Version 7', 1, true) then
        return vim.lsp.rpc.start({ cmd, '--lsp', '--stdio' }, dispatchers)
      end
      vim.notify('using ts ' .. version, vim.log.levels.INFO)
      return vim.lsp.rpc.start({ 'vtsls', '--stdio' }, dispatchers)
    end
    return vim.lsp.rpc.start({ 'tsc', '--lsp', '--stdio' }, dispatchers)
  end,
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      { 'bun.lockb', 'bun.lock' },
      { '.git' },
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
  on_attach = function()
    vim.lsp.inlay_hint.enable(false)
  end,
  -- https://github.com/yioneko/vtsls/blob/main/packages/service/configuration.schema.json
  settings = {
    javascript = {
      inlayHints = {
        variableTypes = {
          enabled = true,
          suppressWhenTypeMatchesName = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        enumMemberValues = {
          enabled = true,
        },
      },
    },
    typescript = {
      inlayHints = {
        variableTypes = {
          enabled = true,
          suppressWhenTypeMatchesName = true,
        },
        propertyDeclarationTypes = {
          enabled = true,
        },
        enumMemberValues = {
          enabled = true,
        },
      },
    },
  },
}
