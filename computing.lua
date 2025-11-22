local M = {}

M.total_out = function(app_tbl)
  local total = 0
  for _, count in pairs(app_tbl) do
    total = total + count
  end
  return total
end

M.total_in = function(apps_tbl)
  local total_in_tbl = {}
  for app_name, _ in pairs(apps_tbl) do
    local total_in = 0
    for _, data in pairs(apps_tbl) do
      local t = data[app_name]
      if t ~= nil then
        total_in = total_in + data[app_name]
      end
    end
    total_in_tbl[app_name] = total_in
  end
  return total_in_tbl
end

return M
