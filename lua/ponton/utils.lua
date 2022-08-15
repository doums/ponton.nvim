--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local fn = vim.fn
local api = vim.api

local M = {}

function M.is_loclist(win)
  local w = win == 0 and api.nvim_get_current_win() or win
  local info = fn.getwininfo(w)
  return info[1].loclist == 1
end

function M.is_quickfix(win)
  local w = win == 0 and api.nvim_get_current_win() or win
  local info = fn.getwininfo(w)
  return info[1].quickfix == 1
end

function M.is_floating(win)
  return vim.api.nvim_win_get_config(win).relative ~= ''
end

return M
