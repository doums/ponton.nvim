--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local M = {}

M.async_load_providers = vim.uv.new_async(vim.schedule_wrap(function()
  local buffer = require('ponton.provider_buffer')
  local fileinfo = require('ponton.provider_fileinfo')
  local lsp = require('ponton.provider_lsp')
  local utils = require('ponton.provider_utils')
  _G.ponton_providers = {
    mode = require('ponton.provider_mode').mode,
    spacer = utils.spacer,
    buffer_name = buffer.buffer_name,
    buffer_changed = buffer.buffer_changed,
    close_window = utils.close_window,
    read_only = buffer.read_only,
    text = utils.text,
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
    lsp_has_error = lsp.lsp_has_error,
    git_branch = utils.git_branch,
    void = utils.void,
  }
  M.async_load_providers:close()
end))

return M
