vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.g.autochdir = true

-- appearance
vim.opt.termguicolors = true
vim.opt.background = 'dark'
vim.opt.showmode = false

-- window
vim.opt.winborder = 'single'
vim.opt.splitbelow = true
vim.opt.splitright = true

-- buffer
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.ruler = false
vim.opt.wrap = false

vim.opt.cursorline = true
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 8
vim.opt.smoothscroll = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.opt.incsearch = true

-- folding
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevelstart = 3
vim.opt.foldminlines = 10

local lsp_foldexpr = 'v:lua.vim.lsp.foldexpr()'
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(e)
    local client = vim.lsp.get_client_by_id(e.data.client_id)
    if client == nil then
      error('not found client')
    end
    if vim.wo.foldexpr ~= lsp_foldexpr and client:supports_method('textDocument/foldingRange') then
      vim.wo.foldexpr = lsp_foldexpr
    end
  end,
})

-- lsp

--- rm log file
local logfile = vim.lsp.log.get_filename()
local logstat = vim.uv.fs_stat(logfile)
if logstat and logstat.size >= 10485760 then -- 10 MB
  vim.fs.rm(logfile, { force = true })
end

--- enable configs
---@type  string[]
local lsp_names = {}
for filename, _ in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp', { depth = 1 }) do
  local name = vim.fn.fnamemodify(filename, ':t:r')

  table.insert(lsp_names, name)
  if not vim.lsp.config[name].manual then
    vim.lsp.enable(name)
  end
end
vim.keymap.set('n', 'grl', function()
  vim.ui.select(lsp_names, { prompt = 'Toggle LSP clients:' }, function(choice)
    if choice == nil then
      return
    end
    local enable = not vim.lsp.is_enabled(choice)
    vim.lsp.enable(choice, enable)
    vim.schedule(function()
      vim.notify(choice .. (enable and ' enabled' or ' disabled'), vim.log.levels.INFO)
    end)
  end)
end, { desc = 'Toggle LSP' })

--- default behavior
vim.lsp.inlay_hint.enable()
vim.diagnostic.config({
  virtual_lines = true,
  float = { source = true },
  severity_sort = true,
  signs = false,
})
