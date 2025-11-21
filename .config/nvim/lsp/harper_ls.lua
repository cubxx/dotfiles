return {
  manual = true,
  cmd = { 'harper-ls', '--stdio' },
  root_markers = { '.harper-dictionary.txt', '.git' },
  -- https://writewithharper.com/docs/integrations/language-server#Configuration
  settings = {
    ['harper-ls'] = {},
  },
}
