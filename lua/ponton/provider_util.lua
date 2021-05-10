--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local b = vim.b

local M = {}

function M.spacer()
  return '%='
end

function M.text(value)
  return value or ''
end

function M.git_branch()
  return b.gitsigns_head or ''
end

return M
