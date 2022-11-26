-- pylsp_venv configuration

local defaults = {
    -- A list of enabled pylsp plugin configurators
    pylsp_plugin_configurators = {
        require("pylsp_venv.configurators.jedi"),
        require("pylsp_venv.configurators.pylsp_mypy"),
    },

    -- A list of enabled virtualenv finders
    virtualenv_finders = {
        require("pylsp_venv.finders.local_venv"),
    },

    -- Config to pass through to `pylsp.setup()`
    server = {},
}

-- Validate user provided config
local function validate_user_config(user_config)
    vim.validate{user_config = {user_config, "t"}}
    vim.validate{
        virtualenv_finders = {user_config.virtualenv_finders, "t", true},
        configurators = {user_config.pylsp_plugin_configurators, "t", true},
        server = {user_config.server, "t", true},
    }

    if user_config.virtualenv_finders then
        for _, finder in ipairs(user_config.virtualenv_finders) do
            vim.validate{finder = {finder, "t"}}
            vim.validate{
                find = {finder.find, "f"},
            }
        end
    end

    if user_config.configurators then
        for _, cfgr in ipairs(user_config.configurators) do
            vim.validate{configurator = {cfgr, "t"}}
            vim.validate{
                plugin = {cfgr.plugin, "s"},
                configure = {cfgr.configure_venv, "f"},
            }
        end
    end
end

local P = {}

function P.setup(user_config)
    user_config = user_config or {}
    validate_user_config(user_config)

    return vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config)
end

return P
