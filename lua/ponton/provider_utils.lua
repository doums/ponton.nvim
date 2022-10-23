--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local g = vim.g

local M = {}

function M.spacer()
  return '%='
end

function M.void(segment, config)
  local length = config.segments[segment].length
  if type(length) == 'string' then
    -- length format is "number%", a percentage of screen width
    local col = vim.o.columns
    local i = tonumber(length:sub(1, -2)) / 100 * col
    return string.format('%' .. i .. 's', '')
  end
  return string.format('%' .. length .. 's', '')
end

function M.text(value)
  return value or ''
end

function M.git_branch()
  return g.gitsigns_head or ''
end

function M.close_window(segment, config)
  local icon = config.segments[segment].icon or '✗'
  return '%'
    .. vim.api.nvim_get_current_win()
    .. '@v:lua.close_win@'
    .. icon
    .. '%X'
end

return M
