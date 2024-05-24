--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local utils = require('ponton.utils')

local M = {}

function M.buffer_not_empty()
  local name = vim.api.nvim_buf_get_name(0)
  if #name == 0 then
    local info = vim.fn.getwininfo(vim.api.nvim_get_current_win())
    if info[1].loclist == 0 and info[1].quickfix == 0 then
      return false
    end
  end
  return true
end

function M.filetype_set()
  if #vim.bo.filetype > 0 then
    return true
  end
  return false
end

function M.is_special_buf()
  return #vim.bo.buftype > 0
end

function M.is_normal_buf()
  return #vim.bo.buftype == 0
end

function M.filetype_empty()
  if #vim.bo.filetype == 0 then
    return true
  end
  return false
end

function M.buftype_not(buftype)
  if type(buftype) == 'table' then
    return not vim.tbl_contains(buftype, vim.bo.buftype)
  end
  return buftype ~= vim.bo.buftype
end

function M.filetype_not(filetype)
  if type(filetype) == 'table' then
    return not vim.tbl_contains(filetype, vim.bo.filetype)
  end
  return filetype ~= vim.bo.filetype
end

function M.win_not_floating()
  return not utils.is_floating(0)
end

function M.is_read_only()
  if vim.bo.readonly == true or vim.bo.modifiable == false then
    return true
  end
  return false
end

function M.is_buffer_changed()
  local info = vim.fn.getbufinfo('')
  if info[1].changed == 1 then
    return true
  end
  return false
end

function M.is_git_repository()
  return vim.b.gitsigns_head and true or false
end

function M.has_active_lsp()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if next(clients) == nil then
    return false
  end
  return true
end

return M
