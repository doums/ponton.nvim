--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local M = {}

function M.line(segment, config)
  local row = vim.api.nvim_win_get_cursor(0)[1]
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
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local count = vim.api.nvim_buf_line_count(0)
  if count == 0 then
    return '100%'
  end
  return string.format('%4d%%%%', 100 * row / count)
end

function M.filetype(segment, config)
  return vim.bo.filetype:upper() or config.segments[segment].placeholder
end

function M.fileencode(segment, config)
  local encode = #vim.bo.fileencoding > 0 and vim.bo.fileencoding
    or vim.o.encoding
  return encode:upper() or config.segments[segment].placeholder
end

function M.fileformat(segment, config)
  return vim.bo.fileformat:upper() or config.segments[segment].placeholder
end

return M
