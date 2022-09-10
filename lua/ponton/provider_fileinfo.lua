--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local api = vim.api
local o = vim.o
local bo = vim.bo

local M = {}

function M.line(segment, config)
  local row = api.nvim_win_get_cursor(0)[1]
  if config.segments[segment].left_adjusted then
    return string.format('%-2d', row)
  end
  return string.format('%3d', row)
end

function M.column(segment, config)
  local col = vim.fn.col('.')
  if config.segments[segment].left_adjusted then
    return string.format('%-2d', col)
  end
  return string.format('%3d', col)
end

function M.line_percent()
  local row = api.nvim_win_get_cursor(0)[1]
  local count = api.nvim_buf_line_count(0)
  if count == 0 then
    return '100%'
  end
  return string.format('%4d%%', 100 * row / count)
end

function M.filetype()
  return bo.filetype:upper() or ''
end

function M.fileencode()
  local encode = #bo.fileencoding > 0 and bo.fileencoding or o.encoding
  return encode:upper() or ''
end

function M.fileformat()
  return bo.fileformat:upper() or ''
end

return M
