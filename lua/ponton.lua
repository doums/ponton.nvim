--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

-- ALIASES -------------------------------------------------------
local cmd = vim.cmd
local api = vim.api
local g = vim.g
local bo = vim.bo
local uv = vim.loop
local opt = vim.opt
local utils = require('ponton.utils')

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
local function hl(name, fg, bg, style, sp)
  local hl_map = { fg = fg, bg = bg, sp = sp }
  if type(style) == 'string' then
    hl_map[style] = 1
  elseif type(style) == 'table' then
    for _, v in ipairs(style) do
      hl_map[v] = 1
    end
  end
  api.nvim_set_hl(0, name, hl_map)
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
  hl(hi_c, active[1], active[2], active[3])
  if inactive then
    hl(hi_nc, inactive[1], inactive[2], inactive[3])
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
        hl('Ponton_mode_' .. kmode, vmode[2][1], vmode[2][2], vmode[2][3])
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
    segment_value = ponton_providers[name](name, _config)
  elseif data.provider and ponton_providers[data.provider] then
    segment_value = ponton_providers[data.provider](name, _config)
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

local function render(segments, hl_end)
  local bar = ''
  for _, name in ipairs(segments) do
    local data = _config.segments[name]
    if check_conditions(data.conditions) then
      if data.margin.left then
        bar = bar .. '%#' .. 'Ponton_' .. name .. '_margin_left#'
        bar = bar .. string.rep(' ', data.margin.left[1])
      end
      if data.decorator.left then
        bar = bar .. '%#' .. 'Ponton_' .. name .. '_decorator_left#'
        bar = bar .. data.decorator.left[1]
      end
      bar = bar .. '%#' .. 'Ponton_' .. name .. '#'
      if name == 'spacer' then
        bar = bar .. ponton_providers.spacer()
      else
        bar = bar
          .. [[%{luaeval('require("ponton").segment')]]
          .. '("'
          .. name
          .. '")}'
      end
      if data.decorator.right then
        bar = bar .. '%#' .. 'Ponton_' .. name .. '_decorator_right#'
        bar = bar .. data.decorator.right[1]
      end
      if data.margin.right then
        bar = bar .. '%#' .. 'Ponton_' .. name .. '_margin_right#'
        bar = bar .. string.rep(' ', data.margin.right[1])
      end
    end
  end
  if hl_end then
    bar = bar .. '%#' .. hl_end .. '#'
  end
  return bar
end

local async_update = uv.new_async(vim.schedule_wrap(function()
  opt.statusline = render(_config.line)
  if
    _config.winbar
    and not utils.is_floating(0)
    and bo.buftype ~= 'quickfix'
    and bo.buftype ~= 'nofile'
    and bo.buftype ~= 'terminal'
  then
    vim.wo.winbar = render(_config.winbar, 'WinBar')
  end
end))

local function parse_box(data, kind)
  if not data then
    return {}
  end
  local parsed = {}
  parsed.left = {}
  parsed.right = {}
  local parse_sub = function(sub, sub_data, i)
    if not sub_data[i] then
      return nil
    end
    if type(sub_data[i]) == kind then
      sub[1] = sub_data[i]
      if vim.tbl_islist(sub_data[3]) then
        sub[2] = sub_data[3]
      end
    elseif vim.tbl_islist(sub_data[i]) then
      sub[1] = sub_data[i][1]
      sub[2] = sub_data[i][2]
    end
    return sub
  end
  if type(data) == kind then
    parsed.left[1] = data
    parsed.right[1] = data
  elseif vim.tbl_islist(data) then
    parsed.left = parse_sub(parsed.left, data, 1)
    parsed.right = parse_sub(parsed.right, data, 2)
  end
  return parsed
end

local function normalize_segments(config, segments)
  local style_keys = { 'decorator', 'margin', 'padding' }
  for _, name in ipairs(segments) do
    local data = config.segments[name]
    local tmp_segment = {}
    data.styles = {}
    tmp_segment.padding = parse_box(data.padding, 'number')
    tmp_segment.margin = parse_box(data.margin, 'number')
    tmp_segment.decorator = parse_box(data.decorator, 'string')
    config.segments[name] = vim.tbl_extend('force', data, tmp_segment)
    if data.style then
      table.insert(data.styles, { name = name, style = data.style })
    end
    if name == 'mode' then
      table.insert(data.styles, { name = 'mode', style = {} })
    end
    for _, v in ipairs(style_keys) do
      if tmp_segment[v].left and tmp_segment[v].left[2] then
        table.insert(data.styles, {
          name = name .. '_' .. v .. '_left',
          style = tmp_segment[v].left[2],
        })
      end
      if tmp_segment[v].right and tmp_segment[v].right[2] then
        table.insert(data.styles, {
          name = name .. '_' .. v .. '_right',
          style = tmp_segment[v].right[2],
        })
      end
    end
  end
  return config
end

local function normalize_config(config)
  config = normalize_segments(config, config.line)
  if config.winbar then
    config = normalize_segments(config, config.winbar)
  end
  return config
end

local function update()
  async_update:send()
end

local function create_autocmd()
  local group_id = api.nvim_create_augroup('ponton', {})
  api.nvim_create_autocmd(autocmd_events, {
    group = group_id,
    pattern = '*',
    callback = function()
      update()
    end,
  })
  api.nvim_create_autocmd('ColorScheme', {
    group = group_id,
    pattern = 'espresso',
    callback = create_highlight,
  })
end

local function setup(config)
  _config = normalize_config(config or default_config)
  create_highlight()
  update()
end

return {
  setup = setup,
  segment = segment,
  update = update,
  create_autocmd = create_autocmd,
}
