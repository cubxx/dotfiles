vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

local opt = vim.opt

-- appearance
opt.termguicolors = true
opt.background = 'dark'
opt.showmode = false
opt.winborder = 'single'

-- editor
opt.number = false -- hide real line number
opt.relativenumber = true
opt.ruler = false
opt.wrap = false

opt.cursorline = true
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.smoothscroll = true

opt.expandtab = true
opt.shiftwidth = 2
opt.smartindent = true

opt.incsearch = true

-- folding
opt.foldmethod = 'expr'
opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
opt.foldlevelstart = 3
opt.foldminlines = 10

local lsp_foldexpr = 'v:lua.vim.lsp.foldexpr()'
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      error('not found client')
    end
    if vim.wo.foldexpr ~= lsp_foldexpr and client:supports_method('textDocument/foldingRange') then
      vim.wo.foldexpr = lsp_foldexpr
    end
  end,
})

-- lsp
-- vim.lsp.config('*', { offset_encoding = 'utf-8' })
for filename, _ in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp', { depth = 1 }) do
  local basename = filename:gsub('%.lua$', '')
  vim.lsp.enable(basename)
end

vim.diagnostic.config({
  virtual_lines = true,
  severity_sort = true,
  signs = false,
})
