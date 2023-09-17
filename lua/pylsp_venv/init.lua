--- Configure virtual environment for pylsp

local P = {}
local config

-- Default configuration
local defaults = {
    -- A list of enabled pylsp plugin configurators
    pylsp_plugin_configurators = {
        require "pylsp_venv.configurators.jedi",
        require "pylsp_venv.configurators.pylsp_mypy",
    },

    -- A list of enabled virtualenv finders
    virtualenv_finders = {
        require "pylsp_venv.finders.local_venv",
    },

    -- Config to pass through to `pylsp.setup()`
    server = {},
}

-- Validate user provided config
local function validate_user_config(user_config)
    vim.validate { user_config = { user_config, "t" } }
    vim.validate {
        virtualenv_finders = { user_config.virtualenv_finders, "t", true },
        configurators = { user_config.pylsp_plugin_configurators, "t", true },
        server = { user_config.server, "t", true },
    }

    if user_config.virtualenv_finders then
        if vim.tbl_isempty(user_config.virtualenv_finders) then
            error "[pylsp_venv] virtualenv_finders must not be empty"
        end
        for _, finder in ipairs(user_config.virtualenv_finders) do
            vim.validate { finder = { finder, "t" } }
            vim.validate {
                find = { finder.find, "f" },
            }
        end
    end

    if user_config.pylsp_plugin_configurators then
        if vim.tbl_isempty(user_config.pylsp_plugin_configurators) then
            error "[pylsp_venv] pylsp_plugin_configurators must not be empty"
        end
        for _, cfgr in ipairs(user_config.pylsp_plugin_configurators) do
            vim.validate { configurator = { cfgr, "t" } }
            vim.validate {
                plugin = { cfgr.plugin, "s" },
                configure = { cfgr.configure_venv, "f" },
            }
        end
    end
end

-- Call each of the configured virtual environment finders until a virtual environment is found
local function get_virtual_env(root_dir)
    for _, finder in ipairs(config.virtualenv_finders) do
        local venv = finder.find(root_dir)
        if venv then
            return venv
        end
    end
    return nil
end

-- Call each of the configured plugin configurators to set the virtualenv for the corresponding plugin
local function add_plugins_venv_config(settings, venv)
    for _, configurator in ipairs(config.pylsp_plugin_configurators) do
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
local function on_new_config(cfg, root_dir)
    -- Look for a virtual environment for the project
    local venv = get_virtual_env(root_dir)

    -- Do nothing if we couldn't find a virtual environment.
    if not venv then
        vim.notify(
            string.format("[pylsp_venv] No virtual environment found for root directory '%s'", root_dir),
            vim.log.levels.DEBUG
        )
        return
    end

    -- Extend the existing settings with minimal defaults
    local settings = vim.tbl_deep_extend(
        "keep",
        cfg.settings,
        { pylsp = { plugins = {} } }
    )
    cfg.settings = settings

    -- Update the plugin configuration
    add_plugins_venv_config(settings.pylsp.plugins, venv)
end

function P.setup(user_config)
    user_config = user_config or {}
    validate_user_config(user_config)

    config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_config)

    local user_on_new_config = config.server.on_new_config

    config.server.on_new_config = function(...)
        if user_on_new_config then
            user_on_new_config(...)
        end
        on_new_config(...)
    end

    require("lspconfig").pylsp.setup(config.server)
end

return P
