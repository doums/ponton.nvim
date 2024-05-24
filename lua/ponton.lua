--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local utils = require('ponton.utils')

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

local function hl(name, fg, bg, style, sp)
  local hl_map = { fg = fg, bg = bg, sp = sp }
  if type(style) == 'string' then
    hl_map[style] = 1
  elseif vim.islist(style) then
    for _, v in ipairs(style) do
      hl_map[v] = 1
    end
  end
  vim.api.nvim_set_hl(0, name, hl_map)
end

local function li(target, source)
  vim.api.nvim_set_hl(0, target, { link = source })
end

local function parse_style(style, name)
  local hi_c = string.format('Ponton_%s_C', name)
  local hi_nc = string.format('Ponton_%s_NC', name)
  local active, inactive
  if vim.islist(style[1]) then
    active = style[1]
    inactive = style[2]
  else
    active = style
  end
  hl(hi_c, active[1], active[2], active[3], active[4])
  if inactive then
    hl(hi_nc, inactive[1], inactive[2], inactive[3], active[4])
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
        if vmode[2] then
          hl('Ponton_mode_' .. kmode, vmode[2][1], vmode[2][2], vmode[2][3])
        else
          li('Ponton_mode_' .. kmode, 'StatusLine')
        end
      end
      li('Ponton_mode_NC', 'Ponton_mode_inactive')
    end
  end
end

local function segment(name)
  local data = _config.segments[name]
  local output = ''
  for _, v in ipairs(data.styles) do
    if vim.api.nvim_get_current_win() == tonumber(vim.g.actual_curwin) then
      li('Ponton_' .. v.name, 'Ponton_' .. v.name .. '_C')
    else
      li('Ponton_' .. v.name, 'Ponton_' .. v.name .. '_NC')
    end
  end
  if data.padding.left then
    local padding = data.padding.left
    if not data.margin.left then
      -- for some reason nvim cuts the first space, add 1 to compensate
      padding = padding + 1
    end
    output = string.rep(' ', padding)
  end
  local segment_value = ''
  if data.text then
    segment_value = ponton_providers.text(data.text)
  elseif data.fn then
    segment_value = data.fn(vim.api.nvim_get_current_buf())
  elseif ponton_providers[name] then
    segment_value = ponton_providers[name](name, _config)
  elseif data.provider and ponton_providers[data.provider] then
    segment_value = ponton_providers[data.provider](name, _config)
  end
  if not segment_value then
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
    output = output .. string.rep(' ', data.padding.right)
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
        bar = bar .. string.rep(' ', data.margin.left)
      end
      bar = bar .. '%#' .. 'Ponton_' .. name .. '#'
      if name == 'spacer' then
        bar = bar .. ponton_providers.spacer()
      else
        bar = bar
          .. '%'
          .. (data.min_width or 0)
          .. [[{%luaeval('require("ponton").segment')]]
          .. '("'
          .. name
          .. '")%}'
      end
      if data.margin.right then
        bar = bar .. '%#' .. 'Ponton_' .. name .. '_margin_right#'
        bar = bar .. string.rep(' ', data.margin.right)
      end
    end
  end
  if hl_end then
    bar = bar .. '%#' .. hl_end .. '#'
  end
  return bar
end

local async_update = vim.uv.new_async(vim.schedule_wrap(function()
  vim.opt.statusline = render(_config.line)
  if
    _config.winbar
    and not utils.is_floating(0)
    and vim.bo.buftype ~= 'nofile'
    and vim.bo.buftype ~= 'terminal'
  then
    vim.wo.winbar = render(_config.winbar, 'WinBar')
  end
  vim.api.nvim__redraw({ statusline = true, winbar = true })
end))

local function remap_box(data)
  if not data then
    return {}
  end
  return {
    left = data[1],
    right = data[2],
  }
end

local function normalize_segments(config, segments)
  for _, name in ipairs(segments) do
    local data = config.segments[name]
    local tmp_segment = {}
    data.styles = {}
    tmp_segment.padding = remap_box(data.padding)
    tmp_segment.margin = remap_box(data.margin)
    config.segments[name] = vim.tbl_extend('force', data, tmp_segment)
    if data.style then
      table.insert(data.styles, { name = name, style = data.style })
    end
    if name == 'mode' then
      table.insert(data.styles, { name = 'mode', style = {} })
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
  local group_id = vim.api.nvim_create_augroup('ponton', {})
  vim.api.nvim_create_autocmd(autocmd_events, {
    group = group_id,
    pattern = '*',
    callback = function()
      update()
    end,
  })
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = group_id,
    pattern = '*',
    callback = create_highlight,
  })
  vim.api.nvim_create_autocmd('User', {
    pattern = { 'GitSignsChanged', 'GitSignsUpdate' },
    callback = function()
      update()
    end,
  })
end

local function setup(config)
  _config = normalize_config(config or default_config)
  create_highlight()
  create_autocmd()
  update()
end

return {
  setup = setup,
  segment = segment,
  update = update,
  create_autocmd = create_autocmd,
}
