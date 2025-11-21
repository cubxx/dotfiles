return {
  'stevearc/oil.nvim',
  lazy = false,
  dependencies = 'nvim-mini/mini.icons',
  keys = {
    { '`', '<cmd>Oil<cr>', desc = 'use Oil' },
  },
  opts = {
    delete_to_trash = true,
    columns = { "icon", "permission", "size", "mtime" },
    view_options = {
      show_hidden = true,
    },
    use_default_keymaps = false,
    keymaps = {
      ['`'] = { 'actions.close', mode = 'n' },
      ['<CR>'] = { 'actions.select' },
      ['g?'] = { 'actions.show_help', mode = 'n' },
      ['gs'] = { 'actions.change_sort', mode = 'n' },
      ['ge'] = { 'actions.open_external' },
      ['gp'] = { 'actions.preview' },
    },
  }
}

