local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error('Failed to clone lazy.nvim: ' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- see https://github.com/LazyVim/LazyVim/blob/c64a61734fc9d45470a72603395c02137802bc6f/lua/lazyvim/util/plugin.lua#L85
local Event = require('lazy.core.handler.event')
Event.mappings.LazyFile = { id = 'LazyFile', event = { 'BufReadPost', 'BufNewFile', 'BufWritePre' } }

-- see https://lazy.folke.io/configuration
require('lazy').setup({
  spec = {
    { import = 'plugins' },
  },
  checker = {
    enabled = false,
  },
  change_detection = {
    enabled = false,
  },
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      reset = false,
      disabled_plugins = { 'gzip', 'tarPlugin', 'zipPlugin', 'tohtml', 'tutor' },
    },
  },
})
