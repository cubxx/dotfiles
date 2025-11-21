return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = 'nvim-mini/mini.icons',
  keys = {
    { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Toggle Pin" },
    { "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
    { "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
  },
  opts = {
    options = {
      indicator = { style = 'none' },
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diag)
        -- icons from https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/components/diagnostics/config.lua
        return (
          diag.error and '󰅚 ' .. diag.error or
          (diag.warning and '󰀪 ' .. diag.warning or '')
        )
      end,
      show_close_icon = false,
      show_buffer_close_icons = false,
      always_show_bufferline = false,
    },
  },
}
