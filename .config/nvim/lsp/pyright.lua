---@type vim.lsp.Config
return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      {
        'pyrightconfig.json',
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
      },
      { '.git' },
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    on_dir(project_root)
  end,
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = 'openFilesOnly',
        typeCheckingMode = 'strict',
      },
    },
  },
  on_attach = function(client)
    local root_dir = client.config.root_dir
    local venvpath = root_dir .. '/.venv'
    if vim.uv.fs_stat(venvpath) then
      local filepath = venvpath .. '/bin/python'
      if not vim.uv.fs_stat(filepath) then
        error('python not exists: ' .. filepath)
      end
      client.settings.python.pythonPath = filepath
    end
  end,
 }
