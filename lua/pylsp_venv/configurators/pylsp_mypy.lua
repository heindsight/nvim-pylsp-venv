-- Configure the python executable for the pylsp_mypy plugin.

local util = require("pylsp_venv.util")

local P = {}

P.plugin = "pylsp_mypy"

function P.configure_venv(config, venv)
    util.validate_configurator_args(config, venv)

    if not config.overrides then
        config.overrides = { true }
    elseif vim.tbl_contains(config.overrides, "--python-executable") then
        return
    end

    local python_exe = util.get_venv_python(venv)
    vim.list_extend(config.overrides, { "--python-executable", python_exe })
end

return P
