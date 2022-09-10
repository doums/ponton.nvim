--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local d = vim.diagnostic
local severity = d.severity

local M = {}

local function get_lsp_diagnostic(s)
  if vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
    return ''
  end
  local count = d.get(0, { severity = s })
  return #count > 0 and tostring(#count) or ''
end

function M.lsp_error()
  return get_lsp_diagnostic(severity.ERROR)
end

function M.lsp_warning()
  return get_lsp_diagnostic(severity.WARN)
end

function M.lsp_information()
  return get_lsp_diagnostic(severity.INFO)
end

function M.lsp_hint()
  return get_lsp_diagnostic(severity.HINT)
end

function M.lsp_has_error(segment, config)
  local count = d.get(0, { severity = severity.ERROR })
  return #count > 0 and config.segments[segment].value or ''
end

return M
