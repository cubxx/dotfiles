return {
  'saghen/blink.cmp',
  event = { "InsertEnter", "CmdlineEnter" },
  version = '1.*',
  opts = {
    keymap = {
      ["<CR>"] = { 'select_and_accept', 'fallback' },
      ["<S-Tab>"] = { "select_prev", 'fallback' },
      ["<Tab>"] = { "select_next", 'fallback' },
      ["<C-]>"] = { "scroll_documentation_up", 'fallback' },
      ["<C-[>"] = { "scroll_documentation_down", 'fallback' },
    },
    completion = {
      documentation = {
        auto_show = true,
      },
      menu = {
        auto_show = true,
      },
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      list = {
        selection = {
          auto_insert = false,
        },
      },
      ghost_text = {
        enabled = true,
      },
    },
    signature = {
      enabled = true,
    },
    cmdline = {
      keymap = { preset = 'inherit' },
      completion = {
        menu = {
          auto_show = true,
        },
        list = {
          selection = {
            auto_insert = false,
          },
        },
        ghost_text = {
          enabled = true,
        },
      },
    },
  },
}
