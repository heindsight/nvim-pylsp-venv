-- Useful helper functions

local lsputil = require("lspconfig.util")

local P = {}

-- Get the path for the python executable in a virtual environment.
function P.get_venv_python(venv)
    local py_paths = { {"bin", "python"}, {"Scripts", "python.exe"}}

    for _, python in ipairs(py_paths) do
        local venv_python = lsputil.path.join(venv, table.unpack(python))
        if lsputil.path.is_file(venv_python) then
            return venv_python
        end
    end
    error(string.format("[pylsp_venv] No python executable found in '%s'", venv))
end

return P
