return {
  manual = true,
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml' },
  -- https://rust-analyzer.github.io/book/configuration.html
  settings = {
    ['rust-analyzer'] = {},
  },
}
