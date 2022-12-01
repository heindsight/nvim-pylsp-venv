--- Configure virtual environment for pylsp

local P = {}

-- Call each of the configured virtual environment finders until a virtual environment is found
local function get_virtual_env(root_dir)
    for _, finder in ipairs(P.config.virtualenv_finders) do
        local venv = finder.find(root_dir)
        if venv then
            return venv
        end
    end
    return nil
end

-- Call each of the configured plugin configurators to set the virtualenv for the corresponding plugin
local function add_plugins_venv_config(settings, venv)
    for _, configurator in ipairs(P.config.pylsp_plugin_configurators) do
        local plugin_settings = settings[configurator.plugin] or {}
        settings[configurator.plugin] = plugin_settings

        vim.notify(
            string.format(
                "[pylsp_venv] Configuring pylsp plugin '%s' to use virtual environment '%s'",
                configurator.plugin,
                venv.path
            ),
            vim.log.levels.DEBUG
        )

        configurator.configure_venv(plugin_settings, venv)
    end
end

-- New config hook function for `lspconfig`.
-- Set this as the `on_new_config` hook function for `pylsp` to inject virtual
-- environment config before a new client is set up.
local function on_new_config(config, root_dir)
    -- Look for a virtual environment for the project
    local venv = get_virtual_env(root_dir)

    -- Do nothing if we couldn't find a virtual environment.
    if not venv then
        vim.notify(
            string.format(
                "[pylsp_venv] No virtual environment found for root directory '%s'", root_dir
            ),
            vim.log.levels.WARN
        )
        return
    end

    -- Extend the existing settings with minimal defaults
    local settings = vim.tbl_deep_extend(
        "keep",
        config.settings,
        { pylsp = { plugins = {} } }
    )
    config.settings = settings

    -- Update the plugin configuration
    add_plugins_venv_config(settings.pylsp.plugins, venv)
end


function P.setup(user_config)
    P.config = require("pylsp_venv.config").setup(user_config)

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
