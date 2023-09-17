local match = require "luassert.match"

describe("pylsp_venv on_new_config", function()
    local pylsp, pylsp_venv, on_new_config

    setup(function()
        pylsp = require("lspconfig").pylsp
        pylsp_venv = require "pylsp_venv"
    end)

    teardown(function()
        pylsp = nil
    end)

    before_each(function()
        stub(pylsp, "setup", function(server_config)
            on_new_config = server_config.on_new_config
        end)

        stub(vim, "notify")
        stub(vim, "validate")
    end)

    after_each(function()
        pylsp.setup:revert()
        vim.notify:revert()
        vim.validate:revert()
    end)

    it("SHOULD call user provided on_new_config", function()
        local user_config = {
            server = { on_new_config = stub() },
            virtualenv_finders = { { find = function() end } },
            pylsp_plugin_configurators = {
                { plugin = "foo", configure_venv = function() end },
            },
        }
        local lsp_config = {}
        pylsp_venv.setup(user_config)

        on_new_config(lsp_config, "root_dir")

        assert.stub(user_config.server.on_new_config).called_with(lsp_config, "root_dir")
    end)

    it("SHOULD do nothing if no virtualenv is found", function()
        local user_config = {
            virtualenv_finders = { { find = function() end } },
            pylsp_plugin_configurators = {
                { plugin = "foo", configure_venv = stub() },
                { plugin = "bar", configure_venv = stub() },
            },
        }
        local lsp_config = {}
        pylsp_venv.setup(user_config)

        on_new_config(lsp_config, "root_dir")

        assert.stub(user_config.pylsp_plugin_configurators[1].configure_venv).not_called()
        assert.stub(user_config.pylsp_plugin_configurators[2].configure_venv).not_called()
    end)

    it("SHOULD call all configurators with venv", function()
        local venv = { name = "venv", path = "/path/to/venv", python_exe = "/path/to/venv/bin/python" }
        local user_config = {
            virtualenv_finders = {
                {
                    find = function()
                        return venv
                    end,
                },
            },
            pylsp_plugin_configurators = {
                {
                    plugin = "foo",
                    configure_venv = function(cfg, env)
                        cfg.venv = env.path
                    end,
                },
                {
                    plugin = "bar",
                    configure_venv = function(cfg, env)
                        cfg.python = env.python_exe
                    end,
                },
            },
        }
        local lsp_config = {}
        pylsp_venv.setup(user_config)

        mock(user_config.pylsp_plugin_configurators)

        on_new_config(lsp_config, "root_dir")

        assert
            .spy(user_config.pylsp_plugin_configurators[1].configure_venv)
            .called_with(match.is_ref(lsp_config.settings.pylsp.plugins.foo), venv)
        assert
            .spy(user_config.pylsp_plugin_configurators[2].configure_venv)
            .called_with(match.is_ref(lsp_config.settings.pylsp.plugins.bar), venv)

        assert.are.same(lsp_config, {
            settings = {
                pylsp = {
                    plugins = {
                        foo = { venv = "/path/to/venv" },
                        bar = { python = "/path/to/venv/bin/python" },
                    },
                },
            },
        })
    end)

    it("SHOULD use first venv found", function()
        local venvs = {
            { name = "venv1", path = "/path/to/venv1", python_exe = "/path/to/venv1/bin/python" },
            { name = "venv2", path = "/path/to/venv2", python_exe = "/path/to/venv2/bin/python" },
        }
        local user_config = {
            virtualenv_finders = {
                { find = function() end },
                {
                    find = function()
                        return venvs[1]
                    end,
                },
                {
                    find = function()
                        -- luacov: disable
                        return venvs[2]
                        -- luacov: enable
                    end,
                },
            },
            pylsp_plugin_configurators = {
                { plugin = "foo", configure_venv = stub() },
            },
        }
        local lsp_config = {}
        pylsp_venv.setup(user_config)

        mock(user_config)

        on_new_config(lsp_config, "root_dir")

        assert.spy(user_config.virtualenv_finders[1].find).called_with("root_dir")
        assert.spy(user_config.virtualenv_finders[2].find).called_with("root_dir")
        assert.spy(user_config.virtualenv_finders[3].find).not_called()

        assert
            .stub(user_config.pylsp_plugin_configurators[1].configure_venv)
            .called_with(match.is_ref(lsp_config.settings.pylsp.plugins.foo), venvs[1])
    end)
end)
