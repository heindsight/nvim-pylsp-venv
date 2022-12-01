-- Useful helper functions

local lsputil = require("lspconfig.util")

local P = {}

-- Get the path for the python executable in a virtual environment.
function P.get_venv_python(venv_path)
    local py_paths = { "bin/python", "Scripts/python.exe" }

    for _, python in ipairs(py_paths) do
        local venv_python = lsputil.path.join(venv_path, python)
        if lsputil.path.is_file(venv_python) then
            return venv_python
        end
    end
    return nil
end

function P.get_venv_info(venv_path)
    local python_exe = P.get_venv_python(venv_path)

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
--  options: (table) optional keyword arguments
--      - recurse: (boolean, default false): If true, search recursively
--      - blacklist (table - list of lua patterns) Exclude matching names from results
--      - whitlelist (table - list of lua patterns) Only include matching names in results
--  Only one of 'blacklist' and 'whitelist' should be used, if both are present,
--  'blacklist' will be ignored.
function P.find_virtual_environments(dir, options)
    local defaults = {
        recurse = false,
        order_by = {"name", "path"}
    }

    options = options or {}
    vim.validate {
        recurse = { options.recurse, "b", true },
        order_by = {options.order_by, "t", true },
    }
    for _, order_item in ipairs(options.order_by or {}) do
        vim.validate { item = {order_item, "s"}}
    end

    options = vim.tbl_deep_extend("keep", options, defaults)

    local star = "*"
    if options.recurse then
        star = "**"
    end

    local found_venvs = {}

    for _, pattern_pfx in ipairs({ "", ".[^.]" }) do
        local pattern = lsputil.path.join(dir, pattern_pfx .. star, "pyvenv.cfg")
        local venv_paths = vim.tbl_map(vim.fs.dirname, vim.fn.glob(pattern, true, true))
        local venvs = vim.tbl_map(P.get_venv_info, venv_paths)
        vim.list_extend(found_venvs, venvs)
    end

    local function cmp(venv_a, venv_b)
        for _, item in ipairs(options.order_by) do
            if venv_a[item] < venv_b[item] then
                return true
            elseif venv_a[item] > venv_b[item] then
                return false
            end
        end
        return false
    end

    table.sort(found_venvs, cmp)

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
