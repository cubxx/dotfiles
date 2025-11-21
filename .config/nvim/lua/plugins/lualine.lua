local function lsp_root_dir()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if not next(clients) then
        return ''
    end

    local client_roots = {}
    for _, client in ipairs(clients) do
        if client.root_dir then
            table.insert(client_roots, {
                name = client.name or client.config.name,
                root_dir = client.root_dir
            })
        end
    end

    if #client_roots == 0 then
        return ''
    end

    local first_root = client_roots[1].root_dir
    local first_name = client_roots[1].name
    for i = 2, #client_roots do
        local current = client_roots[i]
        if current.root_dir ~= first_root then
            error(string.format(
                "LSP root directory mismatch:\n" ..
                "- Client '%s': %s\n" ..
                "- Client '%s': %s",
                first_name, first_root,
                current.name, current.root_dir
            ))
        end
    end

    return first_root
end
return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  opts = {
    options = {
      theme = "auto",
      globalstatus = true,
      component_separators = ''
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch" },
      lualine_c = {
        { "diagnostics" },
        { lsp_root_dir },
      },
      lualine_x = {
        {
          require("lazy.status").updates,
          cond = require("lazy.status").has_updates,
        },
        {
          "diff",
          source = function()
            local gitsigns = vim.b.gitsigns_status_dict
            if gitsigns then
              return {
                added = gitsigns.added,
                modified = gitsigns.changed,
                removed = gitsigns.removed,
              }
            end
          end,
        },
      },
      lualine_y = {
        { "location", padding = { left = 0, right = -1 } },
        { "progress" },
      },
      lualine_z = {
        { "fileformat", show_bomb = true },
        { "encoding", padding = { left = -1, right = 1 } },
      },
    },
    extensions = { "lazy", "oil" },
  },
}
