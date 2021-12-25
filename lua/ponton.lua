--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

-- ALIASES -------------------------------------------------------
local cmd = vim.cmd
local api = vim.api
local g = vim.g
local uv = vim.loop
local opt = vim.opt

-- VARIABLES -----------------------------------------------------
local _config = nil
local default_config = { segments = {} }
local autocmd_events = {
  'ColorScheme',
  'FileType',
  'BufWinEnter',
  'BufReadPost',
  'BufWritePost',
  'WinEnter',
  'BufEnter',
  'SessionLoadPost',
  'FileChangedShellPost',
  'VimResized',
  'TermOpen',
}

_G.ponton_providers = {}
do
  if next(_G.ponton_providers) == nil then
    require('ponton.provider').async_load_providers:send()
  end
end

-- UTILS ---------------------------------------------------------
local function hi(name, foreground, background, style)
  local fg = 'guifg=' .. (foreground or 'NONE')
  local bg = 'guibg=' .. (background or 'NONE')
  local hi_command = string.format('hi %s %s %s', name, fg, bg)
  if style then
    hi_command = string.format('%s gui=%s', hi_command, style)
  end
  cmd(hi_command)
end

local function li(target, source)
  cmd(string.format('hi! link %s %s', target, source))
end

-- CORE ----------------------------------------------------------
local function parse_style(style, name)
  local hi_c = string.format('Ponton_%s_C', name)
  local hi_nc = string.format('Ponton_%s_NC', name)
  local active, inactive
  if vim.tbl_islist(style[1]) then
    active = style[1]
    inactive = style[2]
  else
    active = style
  end
  hi(hi_c, active[1], active[2], active[3])
  if inactive then
    hi(hi_nc, inactive[1], inactive[2], inactive[3])
  else
    li(hi_nc, hi_c)
  end
end

local function create_highlight()
  for name, s in pairs(_config.segments) do
    for _, v in ipairs(s.styles) do
      parse_style(v.style, v.name)
    end
    if name == 'mode' then
      for kmode, vmode in pairs(s.map) do
        hi('Ponton_mode_' .. kmode, vmode[2][1], vmode[2][2], vmode[2][3])
      end
      li('Ponton_mode_NC', 'Ponton_mode_inactive')
    end
  end
end

local function segment(name)
  local data = _config.segments[name]
  local output = ''
  for _, v in ipairs(data.styles) do
    if api.nvim_get_current_win() == tonumber(g.actual_curwin) then
      li('Ponton_' .. v.name, 'Ponton_' .. v.name .. '_C')
    else
      li('Ponton_' .. v.name, 'Ponton_' .. v.name .. '_NC')
    end
  end
  if data.padding.left then
    local padding = data.padding.left[1]
    if not data.decorator.left and not data.margin.left then
      -- for some reason nvim cuts the first space, add 1 to compensate
      padding = padding + 1
    end
    output = string.rep(' ', padding)
  end
  local segment_value = ''
  if data.text then
    segment_value = ponton_providers.text(data.text)
  elseif data.fn then
    segment_value = data.fn(api.nvim_get_current_buf())
  elseif ponton_providers[name] then
    segment_value =  string.format('%s%s%s', ponton_providers[name]())
  end
  if #segment_value == 0 then
    return ''
  end
  if data.prefix then
    output = output .. data.prefix
  end
  output = output .. segment_value
  if data.suffix then
    output = output .. data.suffix
  end
  if data.padding.right then
    output = output .. string.rep(' ', data.padding.right[1])
  end
  return output
end

local function check_conditions(conditions)
  if not conditions then
    return true
  end
  if type(conditions) == 'function' then
    conditions = { conditions }
  end
  for _, condition in pairs(conditions) do
    if type(condition) == 'function' and not condition() then
      return false
    end
    if type(condition) == 'table' and not condition[1](condition[2]) then
      return false
    end
  end
  return true
end

local async_update = uv.new_async(vim.schedule_wrap(function()
  local line = ''
  for _, name in ipairs(_config.line) do
    local data = _config.segments[name]
    if check_conditions(data.conditions) then
      if data.margin.left then
        line = line .. '%#' .. 'Ponton_' .. name .. '_margin_left#'
        line = line .. string.rep(' ', data.margin.left[1])
      end
      if data.decorator.left then
        line = line .. '%#' .. 'Ponton_' .. name .. '_decorator_left#'
        line = line .. data.decorator.left[1]
      end
      line = line .. '%#' .. 'Ponton_' .. name .. '#'
      if name == 'spacer' then
        line = line .. ponton_providers.spacer()
      else
        line = line
          .. [[%{luaeval('require("ponton").segment')]]
          .. '("'
          .. name
          .. '")}'
      end
      if data.decorator.right then
        line = line .. '%#' .. 'Ponton_' .. name .. '_decorator_right#'
        line = line .. data.decorator.right[1]
      end
      if data.margin.right then
        line = line .. '%#' .. 'Ponton_' .. name .. '_margin_right#'
        line = line .. string.rep(' ', data.margin.right[1])
      end
    end
  end
  opt.statusline = line
end))

local function update()
  async_update:send()
end

local function setup(config)
  _config = require('ponton.config').normalize(config or default_config)
  create_highlight()
  update()
end

local function augroup()
  cmd('augroup ponton')
  cmd('autocmd!')
  for _, def in ipairs(autocmd_events) do
    cmd(string.format('autocmd %s * lua require"ponton".update()', def))
  end
  cmd('augroup END')
end

return { setup = setup, segment = segment, update = update, augroup = augroup }
