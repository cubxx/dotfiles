return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = {
    'nvim-mini/mini.icons',
    'rmagatti/auto-session', -- restore session before oil setup
  },
  keys = {
    { '`', '<cmd>Oil<cr>', desc = 'use Oil' },
  },
  opts = {
    delete_to_trash = true,
    columns = { 'icon', 'permission', 'size', 'mtime' },
    view_options = {
      show_hidden = true,
    },
    use_default_keymaps = false,
    keymaps = {
      ['`'] = { 'actions.close', mode = 'n' },
      ['<CR>'] = { 'actions.select', mode = 'n' },
      ['<leader>o?'] = { 'actions.show_help', mode = 'n' },
      ['<leader>os'] = { 'actions.change_sort', mode = 'n' },
      ['<leader>oe'] = { 'actions.open_external' },
      ['<leader>op'] = { 'actions.preview' },
    },
  },
}
