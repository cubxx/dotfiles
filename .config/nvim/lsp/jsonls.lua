return {
  cmd = { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  init_options = {
    provideFormatter = true,
  },
  root_markers = { '.git' },
  -- https://github.com/microsoft/vscode-json-languageservice/blob/main/src/jsonLanguageTypes.ts#L126
  settings = {
    json = {
      validate = { enable = true },
      schemas = {
        {
          url = 'https://json.schemastore.org/package.json',
          fileMatch = { 'package.json' },
        },
        {
          url = 'https://json.schemastore.org/tsconfig',
          fileMatch = { 'tsconfig.json', 'tsconfig.*.json' },
        },
        {
          url = 'https://typedoc.org/schema.json',
          fileMatch = { 'typedoc.json' },
        },
      },
    },
  },
}
