--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local utils = require('ponton.utils')

local M = {}

function M.buffer_name(segment, config)
  local name = vim.api.nvim_buf_get_name(0)
  if utils.is_loclist(0) then
    local ll = vim.fn.getloclist(0, { size = true, title = true })
    return (ll.title or 'll') .. ' ' .. ll.size
  end
  if utils.is_quickfix(0) then
    local qf = vim.fn.getqflist({ id = 0, size = true, title = true })
    return (qf.title or 'qf') .. ' ' .. qf.size
  end
  if #name == 0 then
    return config.segments[segment].empty or ''
  end
  if vim.bo.filetype == 'oil' then
    return 'oil'
  end
  return vim.fn.fnamemodify(name, ':t')
end

function M.buffer_changed(segment, config)
  local cfg = config.segments[segment]
  local info = vim.fn.getbufinfo('')
  if info[1].changed == 1 then
    return cfg.value or cfg.placeholder
  end
  return cfg.placeholder
end

function M.read_only(segment, config)
  local cfg = config.segments[segment]
  if vim.bo.readonly == true or vim.bo.modifiable == false then
    return cfg.value or cfg.placeholder
  end
  return cfg.placeholder
end

return M
