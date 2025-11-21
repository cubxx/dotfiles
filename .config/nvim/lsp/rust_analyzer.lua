return {
  manual = true,
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_dir = function(bufnr, on_dir)
    local root_markers = {
      { 'Cargo.toml' },
      { '.git' },
    }
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()
    on_dir(project_root)
  end,
  -- https://rust-analyzer.github.io/book/configuration.html
  settings = {
    ['rust-analyzer'] = {},
  },
}
