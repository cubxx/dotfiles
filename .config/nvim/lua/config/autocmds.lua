-- see https://neovim.io/doc/user/autocmd.html

-- Auto save
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave', 'QuitPre', 'VimSuspend' }, {
  nested = true, -- emit BufWrite
  callback = function()
    if not vim.bo.modified then
      return
    end
    if vim.bo.buftype == '' then
      vim.cmd('write ++p')
    end
  end,
})

-- Work dir
local function lsp_root_dir()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if not next(clients) then
    return
  end

  local client_roots = {}
  for _, client in ipairs(clients) do
    if client.root_dir then
      table.insert(client_roots, {
        name = client.name or client.config.name,
        root_dir = client.root_dir,
      })
    end
  end

  if #client_roots == 0 then
    return
  end

  -- check if all lsp root are same
  local first_root = client_roots[1].root_dir
  local first_name = client_roots[1].name
  for i = 2, #client_roots do
    local current = client_roots[i]
    if current.root_dir ~= first_root then
      error(
        string.format(
          'LSP root directory mismatch:\n' .. "- Client '%s': %s\n" .. "- Client '%s': %s",
          first_name,
          first_root,
          current.name,
          current.root_dir
        )
      )
    end
  end

  return first_root
end
vim.api.nvim_create_autocmd({ 'BufRead', 'LspAttach' }, {
  callback = function(e)
    -- print(e.file, vim.bo[e.buf].filetype, vim.bo[e.buf].buftype == '')
    local work_dir = lsp_root_dir() or vim.fn.fnamemodify(e.file, ':p:h')
    vim.cmd('lcd ' .. work_dir)
  end,
})

-- Following code from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd('tabdo wincmd =')
    vim.cmd('tabnext ' .. current_tab)
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})
