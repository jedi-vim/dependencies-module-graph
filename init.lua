local os = require "os"
local paths = require "paths"
local mermaid = require "mermaid"
local modules = require "modules"
local compute = require "computing"
local split = require "split"

-- Inicializar esse modulo passando esse valor
if arg[1] == nil then
  print("Nenhum path foi fornecido")
  os.exit(1)
end
local PROJECT_ROOT = arg[1]

-- Inicializar depth no path alvo
local DEPTH = 1
if arg[2] ~= nil and arg[2] ~= "" then
  local d = tonumber(arg[2])
  if d ~= nil and d > 0 then
    DEPTH = d
  end
end

local py_modules_founded = modules.find_py_modules(PROJECT_ROOT, {depth = DEPTH})
local deps_graph = {}

-- Para cada modulo encontrado
for module_name in pairs(py_modules_founded) do
  local module_deps_tbl = {}
  local app_path = paths.concat(PROJECT_ROOT, module_name)
  local founded_py = modules.find_py_files(PROJECT_ROOT, app_path)

  -- Para cada arquivo dentro desse modulo
  for _, file_path in ipairs(founded_py) do
    local file_content = io.lines(file_path)

    -- Para cada linha de import desse arquivo
    for line in file_content do

      -- Para cada linha com import statement
      if string.find(line, "from%s+.+%s+import") then

        -- Para cada outro modulo ja encontrado
        for other_module_name in pairs(py_modules_founded) do
          if module_name ~= other_module_name then
            -- Se esse outro modulo esta presente no import no modulo em analise
            -- print("Arquivo: " .. file_path .. " Linha: " .. line .. " other: " .. other_module_name)
            if string.find(line, "." .. other_module_name) or string.find(line, other_module_name .. ".") then
              local _, imports = split.first_and_rest(line, "from%s+.+%s+import")

              if imports ~= nil then
                local total_imports = split.split(imports, ",")
                local value = module_deps_tbl[other_module_name]
                if value == nil then
                  value = 0
                end
                -- Soma-se quantos imports ESTE modulo faz do OUTRO modulo
                module_deps_tbl[other_module_name] = value + #total_imports
              end
            end
          end
        end
      end -- if string.find ...
    end

  end
  deps_graph[module_name] = module_deps_tbl
  deps_graph[module_name]["total_out"] = compute.total_out(module_deps_tbl)
end

print(mermaid.output_graph(deps_graph))
