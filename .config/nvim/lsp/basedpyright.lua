---@type vim.lsp.Config
return {
  cmd = { 'basedpyright-langserver', '--stdio' },
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
  -- https://docs.basedpyright.com/latest/configuration/language-server-settings
  settings = {
    python = {},
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        -- lint
        diagnosticSeverityOverrides = {
          reportAny = false,
          reportExplicitAny = false,
          reportUnannotatedClassAttribute = false,
          reportImplicitRelativeImport = 'warning',
        },
        -- only for basedpyright
        inlayHints = {
          callArgumentNames = false,
        },
      },
    },
  },
  on_attach = function(client)
    -- venv
    local root_dir = client.config.root_dir
    local venvpath = root_dir .. '/.venv'
    if vim.uv.fs_stat(venvpath) then
      -- python bin
      local python_filepath = venvpath .. '/bin/python'
      if not vim.uv.fs_stat(python_filepath) then
        error('venv python not exists: ' .. python_filepath)
      end
      client.settings.python.pythonPath = python_filepath ---@diagnostic disable-line:inject-field

      -- activate on term
      local activate_filepath = venvpath .. '/bin/activate'
      if not vim.uv.fs_stat(python_filepath) then
        error('venv activate script not exists: ' .. python_filepath)
      end
      vim.api.nvim_create_autocmd('TermOpen', {
        pattern = 'term://*',
        callback = function()
          vim.notify('activate venv')
          vim.schedule(function()
            vim.api.nvim_buf_call(0, function()
              vim.fn.feedkeys('source ' .. activate_filepath .. '\n', 'n')
            end)
          end)
        end,
      })
    end
  end,
}
