return {
  "lewis6991/gitsigns.nvim",
  event = "LazyFile",
  opts = {
    on_attach = function(buffer)
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, '<leader>g' .. l, '<cmd>Gitsigns ' .. r .. '<cr>', { buffer = buffer, desc = desc, silent = true })
      end
      map("n", "]", 'nav_hunk next', "Next Hunk")
      map("n", "[", 'nav_hunk prev', "Prev Hunk")
      map("n", "b", 'blame_line', "Blame Line")
      map("n", "p", 'preview_hunk_inline', "Preview Hunk Inline")
      map("n", "d", 'diffthis', "View Diff")
      map("n", "D", 'diffthis ~', "View HEAD Diff")
    end,
  },
}
