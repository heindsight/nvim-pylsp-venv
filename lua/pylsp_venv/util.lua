-- Useful helper functions

local lsputil = require "lspconfig.util"

local P = {}

-- Get the path for the python executable in a virtual environment.
local function get_venv_python(venv_path)
    local py_paths = { "bin/python", "Scripts/python.exe" }

    for _, python in ipairs(py_paths) do
        local venv_python = lsputil.path.join(venv_path, python)
        if lsputil.path.is_file(venv_python) then
            return venv_python
        end
    end
    return nil
end

-- Get details of a virtual environment
--
-- Params:
--  venv_path: (string) The virtual environment path.
function P.get_venv_info(venv_path)
    local python_exe = get_venv_python(venv_path)

    if not python_exe then
        -- No python executable found, looks like a broken venv.
        return nil
    end

    return {
        name = vim.fs.basename(venv_path),
        path = venv_path,
        python_exe = python_exe,
    }
end

-- Get all virtual environments within a directory
--
-- Params:
--  dir: (string) The directotory to search
function P.find_virtual_environments(dir)
    local found_venvs = {}

    for _, pattern_pfx in ipairs { "*", ".[^.]*" } do
        local pattern = lsputil.path.join(dir, pattern_pfx, "pyvenv.cfg")
        local venv_paths = vim.tbl_map(vim.fs.dirname, vim.fn.glob(pattern, true, true))
        local venvs = vim.tbl_map(P.get_venv_info, venv_paths)
        vim.list_extend(found_venvs, venvs)
    end

    local function cmp_name(venv_a, venv_b)
        return venv_a.name < venv_b.name
    end

    table.sort(found_venvs, cmp_name)

    return found_venvs
end

function P.validate_venv(venv)
    vim.validate {
        name = { venv.name, "s" },
        path = { venv.path, "s" },
        python_exe = { venv.python_exe, "s" },
    }
end

-- Validate plugin configurator arguments
function P.validate_configurator_args(config, venv)
    vim.validate {
        config = { config, "t" },
        venv = { venv, "t" },
    }
    P.validate_venv(venv)
end

return P
