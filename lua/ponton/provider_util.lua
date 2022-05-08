--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local b = vim.b

local M = {}

function M.spacer()
  return '%='
end

function M.void(config)
  local length = config.segments.void.length
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
  return b.gitsigns_head or ''
end

return M
