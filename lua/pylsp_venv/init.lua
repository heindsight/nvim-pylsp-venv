local lsputil = require("lspconfig/util")

local defaults = {
    -- A list of functions for configuring various pylsp plugins.
    pylsp_plugin_configurators = {
        require("pylsp_venv.configurators.jedi"),
        require("pylsp_venv.configurators.pylsp_mypy"),
    },

    -- Config to pass through to `pylsp.setup()`
    server = {},
}

local P = {}

-- Find a virtual environment in the workspace directory.
local function get_virtual_env(workspace)
    for _, pattern in ipairs({ "*", ".*" }) do
        local match = vim.fn.glob(lsputil.path.join(workspace, pattern, "pyvenv.cfg"))
        if match ~= "" then
            return lsputil.path.dirname(match)
        end
    end

    -- No virtual environment found.
    return nil
end

-- Call each of the configured plugin configurators to set the virtualenv for the corresponding plugin
local function add_plugins_venv_config(settings, venv)
    for _, configurator in ipairs(P.config.pylsp_plugin_configurators) do
        local plugin_settings = settings[configurator.plugin] or {}
        settings[configurator.plugin] = plugin_settings

        configurator.configure_venv(plugin_settings, venv)
    end
end

-- New config hook function for `lspconfig`.
-- Set this as the `on_new_config` hook function for `pylsp` to inject virtual
-- environment config before a new client is set up.
local function on_new_config(config, root_dir)
    local venv = get_virtual_env(root_dir)

    -- Do nothing if we couldn"t find a virtual environment.
    if not venv then
        return
    end

    local default_settings = { pylsp = { plugins = {} } }

    -- Extend the existing settings with minimal defaults, so that the configuration
    -- functions can assume that config tables already exist for all the plugins to
    -- configure.
    local settings = vim.tbl_deep_extend(
        "keep",
        config.settings,
        vim.deepcopy(default_settings)
    )
    config.settings = settings

    -- Update the plugin configuration
    add_plugins_venv_config(settings.pylsp.plugins, venv)
end

function P.setup(user_config)
    user_config = user_config or {}

    P.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config)

    local user_on_new_config = P.config.server.on_new_config

    P.config.server.on_new_config = function(...)
        if user_on_new_config then
            user_on_new_config(...)
        end
        on_new_config(...)
    end

    require("lspconfig").pylsp.setup(P.config.server)
end

return P
