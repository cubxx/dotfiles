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

-- window
opt.winborder = 'single'
opt.splitbelow = true
opt.splitright = true

-- buffer
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

--- enable config
---@type  string[]
local manual_lsp = {}
for filename, _ in vim.fs.dir(vim.fn.stdpath('config') .. '/lsp', { depth = 1 }) do
  local name = vim.fn.fnamemodify(filename, ':t:r')
  local config = vim.lsp.config[name]
  if config.manual then
    table.insert(manual_lsp, name)
  else
    vim.lsp.enable(name)
  end
end
if #manual_lsp > 0 then
  vim.keymap.set('n', 'grl', function()
    vim.ui.select(manual_lsp, { prompt = 'Toggle LSP clients:' }, function(choice)
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
end

--- config
vim.lsp.inlay_hint.enable()

vim.diagnostic.config({
  virtual_lines = true,
  float = { source = true },
  severity_sort = true,
  signs = false,
})
