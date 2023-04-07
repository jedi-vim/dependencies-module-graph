local ok_paths, paths = pcall(require, "paths")
if not ok_paths then
  return
end

local ok_inspect, inspect = pcall(require, "inspect")
if not ok_inspect then
  return
end

local ok_split, split = pcall(require, "split")
if not ok_split then
  return
end

local DJANGO_PROJECT_ROOT = "/home/leonam/workspace/cotabest"

-- Primeiro descobrir quais modulos existem no projeto django
function find_django_apps(project_root)
  local django_apps = {}
  for child_dir in paths.iterdirs(project_root) do
    local apps_file = paths.concat(project_root, child_dir, "apps.py")
    if paths.filep(apps_file) then
      django_apps[child_dir] = 0
    end
  end
  return django_apps
end

function find_py_files(dir)
  local PY_FILES = {
    "models.py", "views.py", "services.py",
    "serializers.py", "viewsets.py", "forms.py", "utils.py",
    "tasks.py", "signals.py", "forms.py", "facade.py", "order_status.py",
    "order.py", "invoice.py", "order_product.py", "order_status_webhook.py",
    "order_receipt.py", "order_message.py", "order_precode_data.py", "queries.py"
  }
  local app_path = paths.concat(DJANGO_PROJECT_ROOT, dir)
  local files_tbl = {}
  for file_name in paths.iterfiles(app_path) do
    if contains(PY_FILES, file_name) then
      table.insert(files_tbl, paths.concat(app_path, file_name))
    end
  end
  for sub_dir_name in paths.iterdirs(app_path) do
    local sub_dir_path = paths.concat(DJANGO_PROJECT_ROOT, dir, sub_dir_name)
    for file_name in paths.iterfiles(sub_dir_path) do
      if contains(PY_FILES, file_name) then
        table.insert(files_tbl, paths.concat(sub_dir_path, file_name))
      end
    end
  end
  return files_tbl
end

function contains(tbl, file_name)
  for _, v in ipairs(tbl) do
    if v == file_name then
      return true
    end
  end
  return false
end

local django_apps = find_django_apps(DJANGO_PROJECT_ROOT)
local deps_graph = {}

for app_name in pairs(django_apps) do
  local app_deps_tbl = {}
  local app_path = paths.concat(DJANGO_PROJECT_ROOT, app_name)
  local founded_py = find_py_files(app_path)
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
end
local mermaid = require("mermaid")
mermaid.output_graph(deps_graph)
