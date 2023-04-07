local M = {}

M.output_graph = function(deps_tbl)
  local out = io.open("graph_deps.mermaid", "w")
  if not out then
    return
  end
  out:write("flowchart TB\n")
  for app_name, app_tbl in pairs(deps_tbl) do
    local deps_string = ""
    for deps, _ in pairs(app_tbl) do
      if deps_string == "" then
        deps_string = deps_string .. string.format("%s --> %s", app_name, deps)
      else
        deps_string = deps_string .. string.format(" & %s --> %s", app_name, deps)
      end
    end
    out:write(deps_string .. "\n")
  end
  out:close()
end

return M
