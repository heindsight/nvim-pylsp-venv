local lsputil = require("lspconfig/util")

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

-- Get the path for the python executable in a virtual environment.
local function get_venv_python(venv)
    local bin_dir
    if vim.fn.has("unix") then
        bin_dir = "bin"
    else
        bin_dir = "Scripts"
    end

    return lsputil.path.join(venv, bin_dir, "python")
end

-- A table of functions for configuring various pylsp plugins.
local configure_plugins = {
    -- Configure the python executable for the pylsp_mypy plugin.
    pylsp_mypy = function(config, venv)
        if not config.overrides then
            config.overrides = { true }
        elseif vim.tbl_contains(config.overrides, "--python-executable") then
            return
        end

        vim.list_extend(config.overrides, { "--python-executable", get_venv_python(venv) })
    end,

    -- Configure the virtual environment for the pylsp jedi plugin.
    jedi = function(config, venv)
        if config.environment then
            return
        end
        config.environment = venv
    end
}

-- Iterate over the plugin configuration functions and call each on the associated
-- plugin configuration.
local function add_plugins_venv_config(config, venv)
    for plugin in pairs(configure_plugins) do
        local configurator = configure_plugins[plugin]
        configurator(config[plugin], venv)
    end
end

-- New config hook function for `lspconfig`.
-- Set this as the `on_new_config` hook function for `pylsp` to inject virtual
-- environment config before a new client is set up.
function P.on_new_config(config, root_dir)
    local venv = get_virtual_env(root_dir)

    -- Do nothing if we couldn"t find a virtual environment.
    if not venv then
        return
    end

    local default_settings = {
        pylsp = {
            plugins = {
                jedi = {},
                pylsp_mypy = {},
            }
        }
    }

    -- Extend the existing settings with minimal defaults, so that the configuration
    -- functions can assume that config tables already exist for all the plugins to
    -- configure.
    local settings = vim.tbl_deep_extend(
        "keep",
        config.settings,
        vim.deepcopy(default_settings)
    )

    -- Update the plugin configuration
    add_plugins_venv_config(settings.pylsp.plugins, venv)
    config.settings = settings
end

return P
