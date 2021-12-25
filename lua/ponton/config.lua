--[[ This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at https://mozilla.org/MPL/2.0/. ]]

local _config = {}

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

local function normalize(config)
  local style_keys = { 'decorator', 'margin', 'padding' }
  for _, name in ipairs(config.line) do
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
  _config = config
  return config
end


local M = {
  config = _config,
  normalize = normalize,
}
return M
