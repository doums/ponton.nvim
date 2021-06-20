--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local lsp = vim.lsp

local M = {}

local function get_lsp_diagnostic(type)
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then return '' end
  local count = lsp.diagnostic.get_count(0, type)
  return count > 0 and tostring(count) or ''
end

function M.lsp_error() return get_lsp_diagnostic('Error') end

function M.lsp_warning() return get_lsp_diagnostic('Warning') end

function M.lsp_information() return get_lsp_diagnostic('Information') end

function M.lsp_hint() return get_lsp_diagnostic('Hint') end

return M
