---@type vim.lsp.Config
return {
  cmd = function(dispatchers, config)
    local cmd = 'oxlint'
    if config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', cmd)
      if vim.fn.executable(local_cmd) == 1 then
        cmd = local_cmd
      end
    end
    return vim.lsp.rpc.start({ cmd, '--lsp' }, dispatchers)
  end,
  filetypes = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'vue',
    'svelte',
    'astro',
  },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      { '.oxlintrc.json', '.oxlintrc.jsonc', 'oxlint.config.ts' },
      { 'vite.config.ts' },
      -- find vite plus config with lint field
      { 'vite%-plus', 'lint:' },
      { 'bun.lockb', 'bun.lock' },
      { '.git' },
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
  settings = {
    -- run = 'onType',
    -- configPath = nil,
    -- tsConfigPath = nil,
    -- unusedDisableDirectives = 'allow',
    -- typeAware = false,
    -- disableNestedConfig = false,
    -- fixKind = 'safe_fix',
  },
  before_init = function(init_params, config)
    -- enable typeAware if find oxlint-tsgolint
    local settings = config.settings or {}
    if settings.typeAware ~= nil then
      return
    end

    local has_tsgolint = vim.fn.executable('tsgolint') == 1
    if not has_tsgolint and config.root_dir then
      local local_cmd = vim.fs.joinpath(config.root_dir, 'node_modules/.bin', 'tsgolint')
      has_tsgolint = vim.fn.executable(local_cmd) == 1
    end
    if has_tsgolint then
      settings = vim.tbl_extend('force', settings, { typeAware = true })
    end

    local init_options = config.init_options or {}
    init_options.settings = vim.tbl_extend('force', init_options.settings or {} --[[@as table]], settings)
    init_params.initializationOptions = init_options
  end,
}
