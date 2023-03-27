local ok_paths, paths = pcall(require, "paths")
if not ok_paths then
  return
end

local ok_inspect, inspect = pcall(require, "inspect")
if not ok_inspect then
  return
end

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

local DJANGO_PROJECT_ROOT = "/home/leonam/workspace/cotabest"
local django_apps = find_django_apps(DJANGO_PROJECT_ROOT)

local py_file = io.lines("/home/leonam/workspace/cotabest/payments/models.py")
for line in py_file do
  for app_name, value in pairs(django_apps) do
    if string.find(line, "from " .. app_name .. ".") then
      django_apps[app_name] = value + 1
    end
  end
end
print(inspect(django_apps))
