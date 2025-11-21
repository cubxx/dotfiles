return {
  'lewis6991/gitsigns.nvim',
  event = 'LazyFile',
  opts = {
    on_attach = function(buffer)
      local gitsigns = require('gitsigns')
      local function map(mode, key, fn, desc)
        vim.keymap.set(mode, key, fn, { buffer = buffer, desc = desc })
      end

      map('n', ']c', function()
        if vim.wo.diff then
          vim.cmd.normal({ ']c', bang = true })
        else
          gitsigns.nav_hunk('next')
        end
      end, 'Next hunk')
      map('n', '[c', function()
        if vim.wo.diff then
          vim.cmd.normal({ '[c', bang = true })
        else
          gitsigns.nav_hunk('prev')
        end
      end, 'Prev hunk')

      map('n', '<leader>hb', gitsigns.blame_line, 'Blame Line')
      map('n', '<leader>hp', gitsigns.preview_hunk_inline, 'Preview Hunk Inline')
      map('n', '<leader>hd', gitsigns.diffthis, 'View Diff')
      map('n', '<leader>hD', function()
        gitsigns.diffthis('~')
      end, 'View HEAD Diff')

      map({ 'o', 'x' }, 'ih', gitsigns.select_hunk, 'Select hunk')
    end,
  },
}
