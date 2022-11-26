-- Configure the virtual environment for the pylsp jedi plugin.

local P = {}

P.plugin = "jedi"

function P.configure_venv(config, venv)
    if config.environment then
        return
    end
    config.environment = venv
end

return P
