--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local fn = vim.fn
local bo = vim.bo
local api = vim.api

local M = {}

function M.buffer_name(config)
  local info = fn.getwininfo(api.nvim_get_current_win())
  local name = api.nvim_buf_get_name(0)
  if info[1].loclist == 1 then
    local size = fn.getloclist(0, {size = 1}).size
    return 'loclist ' .. size
  end
  if info[1].quickfix == 1 then
    local size = fn.getqflist({id = 0, size = 1}).size
    return 'quickfix ' .. size
  end
  if #name == 0 then
    return config.segments.buffer_name.empty or ''
  end
  return fn.fnamemodify(name, ':t')
end

function M.buffer_changed(config)
  local info = fn.getbufinfo('')
  if info[1].changed == 1 then
    return config.segments.buffer_changed.value or ''
  end
  return ''
end

function M.read_only(config)
  if bo.readonly == true or bo.modifiable == false then
    return config.segments.read_only.value or ''
  end
  return ''
end

return M
