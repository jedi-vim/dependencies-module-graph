local inspect = require "inspect"

local mermaid = require "mermaid"
local split = require "split"
local dj = require "django"

-- Inicializar esse modulo passando esse valor
end

  end
end

local django_apps = dj.find_django_apps(DJANGO_PROJECT_ROOT)
local deps_graph = {}

for app_name in pairs(django_apps) do
  local app_deps_tbl = {}
  local app_path = paths.concat(DJANGO_PROJECT_ROOT, app_name)
  local founded_py = dj.find_py_files(DJANGO_PROJECT_ROOT, app_path)
  for _, file_path in ipairs(founded_py) do
    local file_content = io.lines(file_path)
    for line in file_content do
      for django_app in pairs(django_apps) do
        if django_app ~= app_name then
          if string.find(line, "from " .. django_app .. ".") then
            local _, imports = split.first_and_rest(line, "from " .. django_app .. ".")
            local total_imports = split.split(imports, ",")
            local value = app_deps_tbl[django_app]
            if value == nil then
              value = 0
            end
            app_deps_tbl[django_app] = value + #total_imports
          end
        end
      end
    end
  end
  deps_graph[app_name] = app_deps_tbl
  deps_graph[app_name]["total_out"] = compute_total_out(app_deps_tbl)
end

local output = mermaid.output_graph(deps_graph)
print(output)
