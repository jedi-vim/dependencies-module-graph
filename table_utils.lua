inspect = require("inspect")

local M = {}


M.contains = function(tbl, file_name)
  for _, v in ipairs(tbl) do
    if v == file_name then
      return true
    end
  end
  return false
end

function _keys(t)
  local keys = {}
  local j = 1

  for k, _ in pairs(t) do
    keys[j] = k
    j = j + 1
  end

  j = 1

  return function()
    local k = keys[j]
    j = j + 1

    return k
  end
end

function _max(t)
  local max = nil
  local key_max = nil
  for key in _keys(t) do
    local item = t[key]
    if max == nil or item["total_out"] > max["total_out"] then
      max = item
      key_max = key
    end
  end
  return key_max, max
end

function _min(t)
  local min = nil
  local key_min = nil
  for key in _keys(t) do
    local item = t[key]
    if min == nil or item["total_out"] <= min["total_out"] then
      min = item
      key_min = key
    end
  end
  return key_min, min
end

function _remove(tbl, key)
  local t = {}
  for k, value in pairs(tbl) do
    if k ~= key then
      t[k] = value
    end
  end
  return t
end

M.iter_deps_tbl = function(app_tbl)
  local app_tbl_ = app_tbl
  return function()
    local k, k_value = _min(app_tbl_)
    app_tbl_ = _remove(app_tbl_, k)
    return k, k_value
  end
end

return M
