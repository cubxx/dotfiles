vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

local opt = vim.opt

-- appearance
opt.termguicolors = true
opt.background = 'dark'
opt.showmode = false

-- editor
opt.number = true
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

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client == nil then
      error('not found client')
    end
    if client:supports_method('textDocument/foldingRange') then
      opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
    end
  end,
})

-- lsp
vim.lsp.config('*', {
  offset_encoding = 'utf-8',
})
for filename, _ in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp', { depth = 1 }) do
  local basename = filename:gsub("%.lua$", "")
  vim.lsp.enable(basename)
end

vim.diagnostic.config({
  virtual_lines = true,
  signs = false,
  severity_sort = true,
})

