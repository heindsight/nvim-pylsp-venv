-- Configure the virtual environment for the pylsp jedi plugin.

local util = require "pylsp_venv.util"

local P = {}

P.plugin = "jedi"

function P.configure_venv(config, venv)
    util.validate_configurator_args(config, venv)

    if config.environment then
        return
    end
    config.environment = venv.path
end

return P
