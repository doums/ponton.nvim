--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local fn = vim.fn
local api = vim.api
local b = vim.b
local bo = vim.bo
local lsp = vim.lsp

local M = {}

function M.buffer_not_empty()
  local name = api.nvim_buf_get_name(0)
  if #name == 0 then
    local info = fn.getwininfo(api.nvim_get_current_win())
    if info[1].loclist == 0
      and info[1].quickfix == 0 then
      return false
    end
  end
  return true
end

function M.filetype_set()
  if #bo.filetype > 0 then return true end
  return false
end

function M.is_read_only()
  if bo.readonly == true or bo.modifiable == false then
    return true
  end
  return false
end

function M.is_buffer_changed()
  local info = fn.getbufinfo('')
  if info[1].changed == 1 then
    return true
  end
  return false
end

function M.is_git_repository()
  return b.gitsigns_head and true or false
end

function M.has_active_lsp()
  local clients = lsp.buf_get_clients(0)
  if next(clients) == nil then
    return false
  end
  return true
end

return M
