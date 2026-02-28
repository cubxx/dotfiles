-- see https://neovim.io/doc/user/autocmd.html
local on = vim.api.nvim_create_autocmd

on({ 'FocusLost', 'BufLeave', 'QuitPre', 'VimSuspend' }, {
  desc = 'Save on blur',
  nested = true, -- emit BufWritePre
  callback = function(e)
    if not vim.bo[e.buf].modified then
      return
    end
    if vim.bo[e.buf].buftype == '' then
      vim.cmd.update()
    end
  end,
})

-- from https://github.com/folke/snacks.nvim/blob/main/lua/snacks/bigfile.lua
vim.filetype.add({
  pattern = {
    ['.*'] = {
      function(path, buf)
        if not path or not buf or vim.bo[buf].filetype == 'bigfile' then
          return
        end
        if path ~= vim.fs.normalize(vim.api.nvim_buf_get_name(buf)) then
          return
        end
        local size = vim.fn.getfsize(path)
        if size <= 0 then
          return
        end
        if size > 1024 * 1024 then
          return 'bigfile'
        end
        local lines = vim.api.nvim_buf_line_count(buf)
        return (size - lines) / lines > 1e3 and 'bigfile' or nil
      end,
    },
  },
})
on('FileType', {
  desc = 'Load big file',
  pattern = 'bigfile',
  callback = function(e)
    vim.api.nvim_buf_call(e.buf, function()
      if vim.fn.exists(':NoMatchParen') ~= 0 then
        vim.cmd([[NoMatchParen]])
      end
      vim.wo.foldmethod = 'manual'
      vim.wo.statuscolumn = ''
      vim.wo.conceallevel = 0
      vim.b.completion = false
      vim.b.minianimate_disable = true
      vim.b.minihipatterns_disable = true
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(e.buf) then
          vim.bo[e.buf].syntax = vim.filetype.match({ buf = e.buf }) or ''
        end
      end)
    end)
  end,
})

---@type table<string,(fun(e:vim.api.keyset.create_autocmd.callback_args,node:TSNode):nil)[]>
local AUTO_REFACTORS = {
  javascript = {
    -- `${}`
    function(e, node)
      if vim.v.char ~= '{' then
        return
      end

      local type = node:type()
      local parent = type == 'string_fragment' and node:parent() or (type == 'string' and node or nil)
      if not parent then
        return
      end

      -- check before char
      local pos = vim.api.nvim_win_get_cursor(0)
      if pos[2] <= 1 then
        return
      end
      local prev = vim.api.nvim_buf_get_text(e.buf, pos[1] - 1, pos[2] - 1, pos[1] - 1, pos[2], {})[1]
      if prev ~= '$' then
        return
      end

      vim.schedule(function() -- FIXME:: input ${ in multi-line template string
        local sr, sc, er, ec = parent:range()
        vim.api.nvim_buf_set_text(e.buf, sr, sc, sr, sc + 1, { '`' })
        vim.api.nvim_buf_set_text(e.buf, er, ec + 1, er, ec + 2, { '`' })
      end)
    end,
    -- /** */
    function(e, node)
      if vim.v.char ~= '*' then
        return
      end

      local type = node:type()
      if type ~= 'comment' then
        return
      end

      vim.schedule(function()
        local sr, sc, er, ec = node:range()
        vim.api.nvim_buf_set_text(e.buf, sr, sc + 3, sr, sc + 3, { ' */' })
      end)
    end,
  },
  python = {
    function(e, node)
      if vim.v.char ~= '{' then
        return
      end

      local type = node:type()
      -- vim.notify(type)
      if type ~= 'string_content' and type ~= 'string_end' then
        return
      end

      local parent = node:parent()
      if not parent then
        return
      end

      local start = parent:child(0)
      if not start then
        return
      end

      local text = vim.treesitter.get_node_text(start, e.buf)
      -- vim.notify(text)
      if text:find('f', 1, true) then
        return
      end

      vim.schedule(function()
        local sr, sc, _, _ = start:range()
        vim.api.nvim_buf_set_text(e.buf, sr, sc, sr, sc, { 'f' })
      end)
    end,
  },
}
AUTO_REFACTORS['typescript'] = AUTO_REFACTORS.javascript
on('InsertCharPre', {
  desc = 'Template string',
  callback = function(e)
    local fns = AUTO_REFACTORS[vim.bo[e.buf].filetype]
    if fns == nil or #fns == 0 then
      return
    end

    local node = vim.treesitter.get_node()
    if node == nil then
      return
    end

    for _, fn in ipairs(fns) do
      fn(e, node)
    end
  end,
})

local CODE_ACTION_KINDS = {
  javascript = { 'source.organizeImports' },
  typescript = { 'source.organizeImports' },
  python = { 'source.organizeImports.ruff', 'source.fixAll.ruff' },
}
-- from: https://github.com/fnune/codeactions-on-save.nvim/blob/main/lua/codeactions-on-save/main.lua
local function handle_code_action(action, buf, timeout_ms, attempts)
  if attempts > 3 then
    vim.notify('Max resolve attempts reached for action ' .. action.kind, vim.log.levels.WARN)
    return
  end

  if action.edit then
    vim.lsp.util.apply_workspace_edit(action.edit, 'utf-16')
  elseif action.command then
    vim.lsp.buf.execute_command(action.command)
  else
    -- neovim:runtime/lua/vim/lsp/buf.lua shows how to run a code action
    -- synchronously. This section is based on that.
    local resolve_result = vim.lsp.buf_request_sync(buf, 'codeAction/resolve', action, timeout_ms)
    if resolve_result then
      for _, resolved_action in pairs(resolve_result) do
        handle_code_action(resolved_action.result, buf, timeout_ms, attempts + 1)
      end
    else
      vim.notify('Failed to resolve code action ' .. action.kind .. ' without edit or command', vim.log.levels.WARN)
    end
  end
end
local function handle_code_actions(kinds, buf, timeout_ms)
  local params = vim.lsp.util.make_range_params(0, 'utf-8')
  params.context = { diagnostics = {}, only = kinds }

  local results, err = vim.lsp.buf_request_sync(buf, 'textDocument/codeAction', params, timeout_ms)
  if err then
    vim.notify('Source code action error: ' .. err, vim.log.levels.ERROR)
    return
  end
  if not results then
    return
  end

  for _, result in pairs(results) do
    for _, action in pairs(result.result or {}) do
      for _, kind in pairs(kinds) do
        if action.kind == kind then
          handle_code_action(action, buf, timeout_ms, 0)
        end
      end
    end
  end
end
on('BufWritePre', {
  desc = 'Code action, Format',
  callback = function(e)
    local kinds = CODE_ACTION_KINDS[vim.bo[e.buf].filetype]
    if kinds ~= nil then
      handle_code_actions(kinds, e.buf, 100)
    end
    vim.cmd('undojoin') -- merge undo node: code action + format
    require('conform').format({ bufnr = e.buf, lsp_format = 'fallback' })
  end,
})

local function lsp_root_dir()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
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
          'LSP root directory mismatch:\n' .. '- %s: %s\n' .. '- %s: %s',
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
on({ 'BufRead', 'LspAttach' }, {
  desc = 'LSP Workspace',
  once = true,
  callback = function()
    -- vim.notify(e.file, vim.bo[e.buf].filetype, vim.bo[e.buf].buftype == '')
    local work_dir = lsp_root_dir()
    if work_dir then
      vim.cmd('lcd ' .. work_dir)
    end
  end,
})

-- Following code from https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
on({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  desc = 'Reload buffer',
  callback = function()
    if vim.o.buftype ~= 'nofile' then
      vim.cmd('checktime')
    end
  end,
})
on('FileType', {
  desc = 'Plain text: wrap',
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})
on('FileType', {
  desc = 'Quickfix jump',
  pattern = 'qf',
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set('n', 'j', 'j<cr><C-w>p', opts)
    vim.keymap.set('n', 'k', 'k<cr><C-w>p', opts)
    vim.keymap.set('n', '<cr>', '<cr><C-w>p<cmd>bdelete<cr>', opts)
  end,
})
