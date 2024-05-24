--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local M = {}

function M.is_loclist(win)
  local w = win == 0 and vim.api.nvim_get_current_win() or win
  local info = vim.fn.getwininfo(w)
  return info[1].loclist == 1
end

function M.is_quickfix(win)
  local w = win == 0 and vim.api.nvim_get_current_win() or win
  local info = vim.fn.getwininfo(w)
  return info[1].quickfix == 1
end

function M.is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ''
end

function _G.close_win(data)
  local status = pcall(vim.api.nvim_win_close, data, false)
  if not status then
    vim.notify('cannot close last window, use :q', vim.log.levels.WARN)
  end
end

return M
