local utils = require "table_utils"

local M = {}

function resolve_trace_weight(weight)
  if weight < 5 then
    return "~~~"
  elseif weight >= 5 and weight < 12 then
    return "-.->"
  elseif weight >= 12 then
    return "==>"
  end
end

M.output_graph = function(deps_tbl)
  local out = "flowchart TB\n"
  for app_name, app_tbl in utils.iter_deps_tbl(deps_tbl) do
    local deps_string = ""
    if app_tbl["total_out"] > 10 then
      for deps, weigth in pairs(app_tbl) do
        if deps ~= "total_out" then
          local line_type = resolve_trace_weight(weigth)
          if deps_string == "" then
            deps_string = deps_string .. string.format("%s %s %s", app_name, line_type, deps)
          else
            deps_string = deps_string .. string.format(" \n %s %s %s", app_name, line_type, deps)
          end
        end
      end
      out = out .. deps_string .. "\n"
    end
  end
  return out
end

return M
