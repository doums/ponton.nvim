--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local fn = vim.fn
local bo = vim.bo
local api = vim.api
local utils = require('ponton.utils')

local M = {}

function M.buffer_name(segment, config)
  local name = api.nvim_buf_get_name(0)
  if utils.is_loclist(0) then
    local size = fn.getloclist(0, { size = 1 }).size
    return 'loclist ' .. size
  end
  if utils.is_quickfix(0) then
    local size = fn.getqflist({ id = 0, size = 1 }).size
    return 'quickfix ' .. size
  end
  if #name == 0 then
    return config.segments[segment].empty or ''
  end
  return fn.fnamemodify(name, ':t')
end

function M.buffer_changed(segment, config)
  local cfg = config.segments[segment]
  local info = fn.getbufinfo('')
  if info[1].changed == 1 then
    return cfg.value or cfg.placeholder
  end
  return cfg.placeholder
end

function M.read_only(segment, config)
  local cfg = config.segments[segment]
  if bo.readonly == true or bo.modifiable == false then
    return cfg.value or cfg.placeholder
  end
  return cfg.placeholder
end

return M
