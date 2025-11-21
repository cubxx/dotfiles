local map = vim.keymap.set

-- Following code from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })

-- Move Lines
map('n', '<A-j>', "<cmd>execute 'move .+' . v:count1<cr>==", { desc = 'Move Down' })
map('n', '<A-k>', "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = 'Move Up' })
map('i', '<A-j>', '<esc><cmd>m .+1<cr>==gi', { desc = 'Move Down' })
map('i', '<A-k>', '<esc><cmd>m .-2<cr>==gi', { desc = 'Move Up' })
map('v', '<A-j>', ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = 'Move Down' })
map('v', '<A-k>', ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = 'Move Up' })

-- buffers
map('n', '<C-s>', '<cmd>update<cr>', { desc = 'Write buffer' })
map('n', '<leader>bd', function()
  local buf = vim.api.nvim_get_current_buf()
  local buftype = vim.bo[buf].buftype
  if buftype ~= '' then
    vim.api.nvim_buf_delete(buf, { force = buftype == 'terminal' })
    return
  end

  vim.cmd('bprev')
  local ok, err = pcall(vim.api.nvim_buf_delete, buf, { force = false }) ---@diagnostic disable-line:param-type-mismatch
  if not ok then
    vim.notify(err, vim.log.levels.ERROR) ---@diagnostic disable-line:param-type-mismatch
    vim.cmd('bnext')
  end
end, { desc = 'Close buffer, Keep window' })

-- lsp
map('n', 'grh', function()
  local opts = { bufnr = 0 }
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(opts), opts)
end, { desc = 'Toggle inlay hint' })
map('n', 'grs', function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    vim.notify('No LSP client attached', vim.log.levels.INFO)
    return
  end

  ---@type  string[]
  local names = {}
  for i, client in ipairs(clients) do
    names[i] = client.name
  end

  vim.ui.select({ 'ALL', table.unpack(names) }, { prompt = 'Restart LSP clients:' }, function(choice)
    if choice == nil then
      return
    end

    local targets = choice == 'ALL' and names or choice
    vim.lsp.enable(targets, false)
    vim.lsp.enable(targets, true)
  end)
end, { desc = 'Restart LSP' })

-- diagnostic
map('n', '[d', function()
  vim.diagnostic.jump({ _highest = true, count = -1 })
end, { desc = 'Prev diagnostic' })
map('n', ']d', function()
  vim.diagnostic.jump({ _highest = true, count = 1 })
end, { desc = 'Next diagnostic' })
map('n', '<leader>dl', vim.diagnostic.setloclist, { desc = 'Buffer diagnostic list' })
map('n', '<leader>da', vim.diagnostic.setqflist, { desc = 'All diagnostic list' })

-- auto undo break-points
map('i', ',', ',<c-g>u')
map('i', '.', '.<c-g>u')
map('i', ';', ';<c-g>u')

-- better indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- quit
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- windows
map('n', '<leader>w', '<C-w>', { desc = 'Window CMD', remap = true })

-- terminal
map('n', '<leader>t', function()
  local term_buf = vim.fn.bufnr('^term://')
  local should_create_term = term_buf == -1
  if should_create_term then
    term_buf = vim.api.nvim_create_buf(false, true)
  end

  -- toggle window
  local term_wins = vim.fn.win_findbuf(term_buf)
  if #term_wins == 0 then
    vim.api.nvim_open_win(term_buf, true, { split = 'below', height = 15 })
    if should_create_term then
      vim.fn.jobstart(vim.o.shell, { term = true }) -- create terminal
    end
    -- vim.cmd.startinsert() -- insert mode
  else
    for _, win in ipairs(term_wins) do
      vim.api.nvim_win_close(win, true)
    end
  end
end, { desc = 'Toggle terminal' })

-- sys copy & paste
map('v', '<leader>y', '"+y', { desc = 'Copy' })
map('v', '<leader>p', '"+p', { desc = 'Paste' })
