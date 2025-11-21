return {
  'rebelot/heirline.nvim',
  event = 'BufEnter',
  dependencies = 'nvim-mini/mini.icons',
  config = function()
    local conditions = require('heirline.conditions')
    local utils = require('heirline.utils')
    local colors = {
      red = utils.get_highlight('DiagnosticError').fg,
      green = utils.get_highlight('String').fg,
      blue = utils.get_highlight('Function').fg,
      gray = utils.get_highlight('NonText').fg,
      orange = utils.get_highlight('Constant').fg,
      purple = utils.get_highlight('Statement').fg,
      cyan = utils.get_highlight('Special').fg,
    }
    local get_buf_option = function(comp, name)
      return vim.api.nvim_get_option_value(name, { buf = comp.bufnr or 0 })
    end

    local S = { provider = ' ' }
    local F = { provider = '%=' }
    local P = function(comp)
      table.insert(comp, S)
      return comp
    end

    local ViMode = {
      init = function(self)
        self.mode = vim.fn.mode(1) -- :h mode()
      end,
      static = {
        texts = {
          ['n'] = 'NORMAL',
          ['no'] = 'O-PENDING',
          ['nov'] = 'O-PENDING',
          ['noV'] = 'O-PENDING',
          ['no\22'] = 'O-PENDING',
          ['niI'] = 'NORMAL',
          ['niR'] = 'NORMAL',
          ['niV'] = 'NORMAL',
          ['nt'] = 'NORMAL',
          ['ntT'] = 'NORMAL',
          ['v'] = 'VISUAL',
          ['vs'] = 'VISUAL',
          ['V'] = 'V-LINE',
          ['Vs'] = 'V-LINE',
          ['\22'] = 'V-BLOCK',
          ['\22s'] = 'V-BLOCK',
          ['s'] = 'SELECT',
          ['S'] = 'S-LINE',
          ['\19'] = 'S-BLOCK',
          ['i'] = 'INSERT',
          ['ic'] = 'INSERT',
          ['ix'] = 'INSERT',
          ['R'] = 'REPLACE',
          ['Rc'] = 'REPLACE',
          ['Rx'] = 'REPLACE',
          ['Rv'] = 'V-REPLACE',
          ['Rvc'] = 'V-REPLACE',
          ['Rvx'] = 'V-REPLACE',
          ['c'] = 'COMMAND',
          ['cv'] = 'EX',
          ['ce'] = 'EX',
          ['r'] = 'REPLACE',
          ['rm'] = 'MORE',
          ['r?'] = 'CONFIRM',
          ['!'] = 'SHELL',
          ['t'] = 'TERMINAL',
        },
        colors = {
          n = 'blue',
          i = 'green',
          v = 'purple',
          V = 'purple',
          ['\22'] = 'purple',
          c = 'orange',
          s = 'cyan',
          S = 'cyan',
          ['\19'] = 'cyan',
          R = 'red',
          r = 'red',
          ['!'] = 'cyan',
          t = 'cyan',
        },
      },
      provider = function(self)
        return self.texts[self.mode]
      end,
      hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.colors[mode], bold = true }
      end,
      update = {
        'ModeChanged',
        pattern = '*:*',
        callback = vim.schedule_wrap(function()
          vim.cmd('redrawstatus')
        end),
      },
    }
    local Git = {
      condition = conditions.is_git_repo,
      hl = {},
      init = function(self)
        self.status = vim.b.gitsigns_status_dict
      end,
      {
        provider = function(self)
          return ' ' .. self.status.head
        end,
        hl = { bold = true },
      },
    }
    for key, value in pairs({ Added = '+', Removed = '-', Changed = '~' }) do
      table.insert(Git, {
        provider = function(self)
          local count = self.status[key:lower()] or 0
          return count > 0 and (value .. count)
        end,
        hl = { fg = utils.get_highlight('diff' .. key).fg },
      })
    end

    local Diagnostics = {
      condition = conditions.has_diagnostics,
      update = { 'DiagnosticChanged', 'BufEnter' },
    }
    for key, value in pairs({
      Error = '󰅚 ',
      Warn = '󰀪 ',
      Info = '󰋽 ',
      Hint = '󰌶 ',
    }) do
      table.insert(Diagnostics, {
        provider = function()
          local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[key:upper()] })
          return count > 0 and (value .. count)
        end,
        hl = 'Diagnostic' .. key,
      })
    end

    local WorkDir = {
      provider = function()
        local cwd = vim.fn.getcwd(0)
        cwd = vim.fn.fnamemodify(cwd, ':~')
        -- if not conditions.width_percent_below(#cwd, 0.25) then
        --   cwd = vim.fn.pathshorten(cwd)
        -- end
        local trail = cwd:sub(-1) == '/' and '' or '/'
        return ' ' .. cwd .. trail
      end,
    }

    local Lsp = {
      condition = conditions.lsp_attached,
      {
        update = {
          'LspProgress',
          'LspRequest',
          callback = function()
            vim.cmd.redrawstatus()
          end,
        },
        provider = function()
          return '%<' .. vim.lsp.status() .. ' %'
        end,
      },
      S,
      {
        update = { 'LspAttach', 'LspDetach', 'BufEnter' },
        provider = function()
          local names = {}
          for _, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
            table.insert(names, server.name)
          end
          return ' [' .. table.concat(names, ' ') .. ']'
        end,
        hl = { bold = true },
      },
    }

    local Location = { provider = '%l:%c %P' }
    local FileInfo = {
      static = {
        eol_texts = { unix = 'LF', dos = 'CRLF', mac = 'CR' },
      },
      init = function(self)
        self.eol = self.eol_texts[get_buf_option(self, 'fileformat')]
        self.encoding = vim.opt.fileencoding:get() .. (vim.opt.bomb:get() and ' [BOM]' or '')
      end,
      update = { 'BufReadPost' },
      provider = function(self)
        return self.encoding .. ' ' .. self.eol
      end,
    }

    local FileIcon = {
      init = function(self)
        local icons = require('mini.icons')
        local filetype = get_buf_option(self, 'filetype')
        if filetype == '' then
          self.icon, self.icon_hl, _ = icons.get('file', self.filepath)
        else
          self.icon, self.icon_hl, _ = icons.get('filetype', filetype)
        end
      end,
      provider = function(self)
        return self.icon
      end,
      hl = function(self)
        return self.icon_hl
      end,
    }
    local FileName = {
      provider = function(self)
        local name = 'unknown'
        local filepath = self.filepath
        if filepath == '' then
          local buftype = get_buf_option(self, 'buftype')
          name = buftype == '' and '[No name]' or buftype
        else
          name = vim.fn.fnamemodify(filepath, ':t')
        end
        return ' ' .. name
      end,
      hl = function(self)
        return self.is_active and 'TabLineSel' or 'TabLine'
      end,
    }
    local FileFlag = {
      condition = function(self)
        if get_buf_option(self, 'buftype') ~= '' then -- only for file buf
          return false
        end

        self.flag = nil
        if get_buf_option(self, 'modified') then
          self.flag = ''
        elseif not get_buf_option(self, 'modifiable') or get_buf_option(self, 'readonly') then
          self.flag = ''
        end
        return self.flag
      end,
      provider = function(self)
        return self.flag
      end,
    }
    local FilePath = {
      provider = function()
        local relative = vim.fn.expand('%')
        return relative == '' and vim.api.nvim_buf_get_name(0) or relative
      end,
    }
    local BufferLine = utils.make_buflist({
      init = function(self)
        self.filepath = vim.api.nvim_buf_get_name(self.bufnr or 0)
      end,
      -- P(FileIcon),
      P(FileName),
      -- P(FileFlag),
    }, { provider = '', hl = { fg = 'gray' } }, { provider = '', hl = { fg = 'gray' } })

    vim.o.showtabline = 2
    vim.o.laststatus = 3
    require('heirline').setup({
      opts = {
        colors = colors,
        disable_winbar_cb = function(e)
          return not vim.api.nvim_buf_is_valid(e.buf)
            or conditions.buffer_matches({
              buftype = { 'nofile', 'prompt', 'help', 'quickfix' },
              filetype = { '^git.*', 'fugitive', 'Trouble', 'dashboard' },
            }, e.buf)
        end,
      },
      winbar = {
        fallthrough = false,
        {
          -- condition = function()
          --   return vim.bo.buftype == ''
          -- end,
          init = function(self)
            self.filepath = vim.api.nvim_buf_get_name(0)
          end,
          S,
          P(FileIcon),
          P(FileFlag),
          P(FilePath),
        },
      },
      tabline = { BufferLine },
      statusline = {
        S,
        P(ViMode),
        P(Git),
        P(Diagnostics),
        P(WorkDir),
        F,
        P(Lsp),
        P(FileInfo),
        P(Location),
      },
    })
  end,
}
