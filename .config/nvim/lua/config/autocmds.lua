-- see https://neovim.io/doc/user/autocmd.html

-- Restore teminal cursor
vim.api.nvim_create_autocmd({ 'UILeave', 'VimLeave', 'VimLeavePre' }, {
  command = 'set guicursor=a:ver25'
})

-- Auto save and format
local function format(f)
  if f.filetype == 'markdown' then
    vim.cmd('silent !prettier -w % >/dev/null')
  end
end
vim.api.nvim_create_autocmd({ 'CmdlineEnter', 'FocusLost', 'BufLeave', 'BufDelete' }, {
  callback = function()
    if vim.bo.buftype == '' then
      vim.cmd('update ++p')
      format(vim.bo)
    end
  end,
})

-- Following code from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
