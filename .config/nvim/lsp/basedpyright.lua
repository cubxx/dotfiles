---@type vim.lsp.Config
return {
  manual = true,
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
  on_attach = function()
    vim.opt.keywordprg = ':Man' -- press K to show hover
  end,
  -- https://docs.basedpyright.com/latest/configuration/language-server-settings
  settings = {
    python = {},
    basedpyright = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        useTypingExtensions = true,
        -- lint
        diagnosticSeverityOverrides = {
          reportAny = false,
          reportExplicitAny = false,
          reportUnannotatedClassAttribute = false,
          reportUnusedCallResult = false,
          reportMissingParameterType = false,
          reportUnknownParameterType = false,
          reportUnknownArgumentType = false,
          reportUnknownMemberType = false,
          reportImplicitRelativeImport = 'warning',
        },
        -- only for basedpyright
        inlayHints = {
          callArgumentNames = false,
        },
      },
    },
  },
}
