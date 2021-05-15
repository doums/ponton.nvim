## ponton.nvim

A light and **fast** statusline.

Requires neovim 0.5+

### install
Example with [paq-nvim](https://github.com/savq/paq-nvim/)
```lua
-- ...
paq 'doums/ponton.nvim'
```

### configuration
```lua
-- ...
hi('StatusLineNC', '#BDAE9D', '#432717')
local line_bg = '#432717'
require'ponton'.setup({
  line = {'active_mark_start', 'mode', 'buffer_name', 'buffer_changed',
    'read_only', 'git_branch', 'spacer', 'lsp_status', 'lsp_error',
    'lsp_warning', 'lsp_information', 'lsp_hint', 'line', 'sep',
    'column', 'line_percent', 'active_mark_end'},
  segments = {
    mode = {
      map = {
        normal = {'▲', {'#BDAE9D', line_bg, 'bold'}},
        insert = {'◆', {'#049B0A', line_bg, 'bold'}},
        replace = {'◆', {'#C75450', line_bg, 'bold'}},
        visual = {'◆', {'#43A8ED', line_bg, 'bold'}},
        v_line = {'━', {'#43A8ED', line_bg, 'bold'}},
        v_block = {'■', {'#43A8ED', line_bg, 'bold'}},
        select = {'■', {'#3592C4', line_bg, 'bold'}},
        command = {'▼', {'#BDAE9D', line_bg, 'bold'}},
        shell_ex = {'●', {'#93896C', line_bg, 'bold'}},
        terminal = {'●', {'#049B0A', line_bg, 'bold'}},
        prompt = {'▼', {'#BDAE9D', line_bg, 'bold'}},
        inactive = {' ', {line_bg, line_bg}},
      },
      margin = {1, 1},
    },
    buffer_name = {
      style = {'#BDAE9D', '#2A190E', 'bold'},
      empty = nil,
      padding = {1, 1},
      margin = {1, 1},
      decorator = {'', '', {'#2A190E', line_bg}},
      condition = require'ponton.condition'.buffer_not_empty
    },
    buffer_changed = {
      style = {'#DF824C', line_bg, 'bold'},
      value = '†',
      padding = {nil, 1},
    },
    read_only = {
      style = {'#C75450', line_bg, 'bold'},
      value = '',
      padding = {nil, 1},
      condition = require'ponton.condition'.is_read_only
    },
    spacer = {
      style = {line_bg, line_bg},
    },
    sep = {
      style = {'#BDAE9D', line_bg},
      text = '⏽',
    },
    line_percent = {
      style = {'#BDAE9D', line_bg},
      padding = {nil, 1},
    },
    line = {
      style = {'#BDAE9D', line_bg},
      padding = {1},
    },
    column = {
      style = {'#BDAE9D', line_bg},
      left_adjusted = true,
      padding = {nil, 1},
    },
    git_branch = {
      style = {'#C5656B', line_bg},
      padding = {1, 1},
      prefix = ' ',
    },
    lsp_status = {
      style = {'#C5656B', line_bg},
      fn = require'lsp_status'.status,
      padding = {nil, 2},
      prefix = '󰣪 ',
    },
    lsp_error = {
      style = {'#FF0000', line_bg, 'bold'},
      padding = {nil, 1},
      prefix = '×',
    },
    lsp_warning = {
      style = {'#FFFF00', line_bg, 'bold'},
      padding = {nil, 1},
      prefix = '•',
    },
    lsp_information = {
      style = {'#FFFFCC', line_bg},
      padding = {nil, 1},
      prefix = '~',
    },
    lsp_hint = {
      style = {'#F49810', line_bg},
      padding = {nil, 1},
      prefix = '~',
    },
    active_mark_start = {
      style = {{'#DF824C', line_bg}, {line_bg, line_bg}},
      text = '▌',
    },
    active_mark_end = {
      style = {{'#DF824C', line_bg}, {line_bg, line_bg}},
      text = '▐',
    },
  },
})
```

### inspired by
[galaxyline.nvim](https://github.com/glepnir/galaxyline.nvim)

### license
Mozilla Public License 2.0
