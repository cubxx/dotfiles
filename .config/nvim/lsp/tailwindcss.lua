return {
  manual = true,
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = { 'html', 'css', 'javascript', 'typescript' },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  root_markers = { '.git' },
  -- https://github.com/tailwindlabs/tailwindcss-intellisense
  settings = {
    tailwindCSS = {
      emmetCompletions = true,
      validate = true,
      classFunctions = { '[a-z-]+' },
    },
  },
}
