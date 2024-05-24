--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local M = {}

local modes_map = {
  { '^n', 'normal' },
  { '^v', 'visual' },
  { '^V', 'v_line' },
  { '^', 'v_block' },
  { '^s', 'select' },
  { '^S', 'select' },
  { '^', 'select' },
  { '^i', 'insert' },
  { '^R', 'replace' },
  { '^c', 'command' },
  { '^r', 'prompt' },
  { '^!', 'shell_ex' },
  { '^t', 'terminal' },
}

function M.mode(segment, config)
  if vim.api.nvim_get_current_win() ~= tonumber(vim.g.actual_curwin) then
    return config.segments[segment].map.inactive[1]
  end
  local mod = vim.api.nvim_get_mode()
  for _, v in ipairs(modes_map) do
    if string.find(mod.mode, v[1]) then
      vim.cmd(
        string.format('hi! link %s %s', 'Ponton_mode_C', 'Ponton_mode_' .. v[2])
      )
      return config.segments[segment].map[v[2]][1]
    end
  end
  return '�'
end

return M
