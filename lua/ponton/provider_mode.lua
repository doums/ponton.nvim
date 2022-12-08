--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local cmd = vim.cmd
local api = vim.api
local g = vim.g

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
  if api.nvim_get_current_win() ~= tonumber(g.actual_curwin) then
    return config.segments[segment].map.inactive[1]
  end
  local mod = api.nvim_get_mode()
  for _, v in ipairs(modes_map) do
    if string.find(mod.mode, v[1]) then
      cmd(
        string.format('hi! link %s %s', 'Ponton_mode_C', 'Ponton_mode_' .. v[2])
      )
      return config.segments[segment].map[v[2]][1]
    end
  end
  return '�'
end

return M
