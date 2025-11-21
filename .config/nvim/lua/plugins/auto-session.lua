return {
  'rmagatti/auto-session',
  lazy = false,
  config = function()
    vim.o.sessionoptions = 'buffers,curdir,folds,help,tabpages,winsize,winpos,terminal'
    require('auto-session').setup({
      auto_create = false,
      post_restore_cmds = {
        -- Remove empty buffers
        function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.fn.getbufinfo(buf)[1].lnum == 0 then -- remove empty buffer
              vim.api.nvim_buf_delete(buf, { force = true })
            end
          end
        end,
        -- Set current dir
        function(name)
          vim.cmd.cd(name)
        end,
      },
    })
  end,
}
