return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
    require('auto-session').setup({ auto_create = false })
  end,
}
