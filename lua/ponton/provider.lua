--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local uv = vim.loop

local M = {}

M.async_load_providers = uv.new_async(vim.schedule_wrap(function ()
  local buffer = require'ponton.provider_buffer'
  local fileinfo = require'ponton.provider_fileinfo'
  local lsp = require'ponton.provider_lsp'
  local util = require'ponton.provider_util'
  _G.ponton_providers = {
    mode = require'ponton.provider_mode'.mode,
    spacer = util.spacer,
    buffer_name = buffer.buffer_name,
    buffer_changed = buffer.buffer_changed,
    read_only = buffer.read_only,
    text = util.text,
    line = fileinfo.line,
    column = fileinfo.column,
    line_percent = fileinfo.line_percent,
    filetype = fileinfo.filetype,
    fileencode = fileinfo.fileencode,
    fileformat = fileinfo.fileformat,
    lsp_error = lsp.lsp_error,
    lsp_warning = lsp.lsp_warning,
    lsp_information = lsp.lsp_information,
    lsp_hint = lsp.lsp_hint,
    git_branch = util.git_branch,
  }
  M.async_load_providers:close()
end))

return M
