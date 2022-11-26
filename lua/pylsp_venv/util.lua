-- Useful helper functions

local lsputil = require("lspconfig.util")

local P = {}

-- Get the path for the python executable in a virtual environment.
function P.get_venv_python(venv)
    local bin_dir
    if vim.fn.has("unix") then
        bin_dir = "bin"
    else
        bin_dir = "Scripts"
    end

    return lsputil.path.join(venv, bin_dir, "python")
end

return P
