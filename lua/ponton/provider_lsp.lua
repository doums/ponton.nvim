--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local d = vim.diagnostic
local severity = d.severity

local M = {}

local function get_lsp_diagnostic(s, placeholder)
  if vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0 })) then
    return
  end
  local count = d.get(0, { severity = s })
  return #count > 0 and tostring(#count) or placeholder
end

function M.lsp_error(segment, config)
  local cfg = config.segments[segment]
  return get_lsp_diagnostic(severity.ERROR, cfg.placeholder)
end

function M.lsp_warning(segment, config)
  local cfg = config.segments[segment]
  return get_lsp_diagnostic(severity.WARN, cfg.placeholder)
end

function M.lsp_information(segment, config)
  local cfg = config.segments[segment]
  return get_lsp_diagnostic(severity.INFO, cfg.placeholder)
end

function M.lsp_hint(segment, config)
  local cfg = config.segments[segment]
  return get_lsp_diagnostic(severity.HINT, cfg.placeholder)
end

function M.lsp_has_error(segment, config)
  local cfg = config.segments[segment]
  local count = d.get(0, { severity = severity.ERROR })
  return #count > 0 and cfg.value or cfg.placeholder
end

return M
