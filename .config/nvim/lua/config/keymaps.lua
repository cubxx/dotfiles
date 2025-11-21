local map = vim.keymap.set

-- Following code from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<leader>b[", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>b]", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close Buffer" })
map("n", "<leader>bw", "<cmd>update<cr>", { desc = "Save Buffer" })

-- diagnostic
map('n', '<leader>ds', function() vim.diagnostic.open_float() end, { desc = 'Detail' })
map('n', '<leader>dl', function() vim.diagnostic.setloclist() end, { desc = 'Diagnostic list' })
map('n', '<leader>dq', function() vim.diagnostic.setqflist() end, { desc = 'Quick fix list' })
map('n', '<leader>dt', function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, { desc = 'Toggle Diagnostic' })
map('n', '<leader>d[', function() vim.diagnostic.jump({ count = -1 }) end, { desc = 'Prev Diagnostic' })
map('n', '<leader>d]', function() vim.diagnostic.jump({ count = 1 }) end, { desc = 'Next Diagnostic' })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- better indenting
map("x", "<", "<gv")
map("x", ">", ">gv")

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })

-- windows
map("n", "<leader>w", "<C-W>", { desc = "Window CMD", remap = true })
