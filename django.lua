local paths = require "paths"
local split = require "split"
local utils = require "table_utils"

local M = {}

M.find_django_apps = function(project_root)
  local django_apps = {}
  for child_dir in paths.iterdirs(project_root) do
    local apps_file = paths.concat(project_root, child_dir, "apps.py")
    if paths.filep(apps_file) then
      django_apps[child_dir] = 0
    end
  end
  return django_apps
end

-- Preciso achar todos os arquivos py dentro uma django_app
M.find_py_files = function(project_root, dir)
  local PY_FILES = {
    "models.py",
    "views.py",
    "services.py",
    "serializers.py",
    "viewsets.py",
    "forms.py",
    "utils.py",
    "tasks.py",
    "signals.py",
    "managers.py",
    "forms.py",
    "facade.py",
    "order_status.py",
    "order.py",
    "invoice.py",
    "order_product.py",
    "order_status_webhook.py",
    "order_receipt.py",
    "order_message.py",
    "order_precode_data.py",
    "queries.py"
  }
  local app_path = paths.concat(project_root, dir)
  local files_tbl = {}
  for file_name in paths.iterfiles(app_path) do
    if utils.contains(PY_FILES, file_name) then
      table.insert(files_tbl, paths.concat(app_path, file_name))
    end
  end
  for sub_dir_name in paths.iterdirs(app_path) do
    local sub_dir_path = paths.concat(project_root, dir, sub_dir_name)
    for file_name in paths.iterfiles(sub_dir_path) do
      if utils.contains(PY_FILES, file_name) then
        table.insert(files_tbl, paths.concat(sub_dir_path, file_name))
      end
    end
  end
  return files_tbl
end

return M
