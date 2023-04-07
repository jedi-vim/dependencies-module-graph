local M = {}

function resolve_trace_weight(weight)
  if weight < 5 then
    return "~~~"
  elseif weight >= 5 and weight < 8 then
    return "-.->"
  elseif weight >= 8 and weight < 15 then
    return "-->"
  elseif weight >= 15 then
    return "==>"
  end
end

M.output_graph = function(deps_tbl)
  local out = io.open("graph_deps.mermaid", "w")
  if not out then
    return
  end
  out:write("flowchart TB\n")
  for app_name, app_tbl in pairs(deps_tbl) do
    local deps_string = ""
    for deps, weigth in pairs(app_tbl) do
      local line_type = resolve_trace_weight(weigth)
      if deps_string == "" then
        deps_string = deps_string .. string.format("%s %s %s", app_name, line_type, deps)
      else
        deps_string = deps_string .. string.format(" & %s %s %s", app_name, line_type, deps)
      end
    end
    out:write(deps_string .. "\n")
  end
  out:close()
end

return M
