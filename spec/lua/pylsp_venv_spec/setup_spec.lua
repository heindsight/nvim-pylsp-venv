require "spec.helpers"

describe("pylsp_venv setup", function()
    local match, pylsp, pylsp_venv

    setup(function()
        match = require "luassert.match"
        pylsp = require("lspconfig").pylsp
        pylsp_venv = require "pylsp_venv"
    end)

    teardown(function()
        pylsp = nil
    end)

    before_each(function()
        stub(pylsp, "setup")
    end)

    after_each(function()
        pylsp.setup:revert()
    end)

    it("SHOULD setup pylsp", function()
        pylsp_venv.setup()

        assert.stub(pylsp.setup).called()
    end)

    it("SHOULD pass through pylsp server config", function()
        local on_attach = function() end
        local settings = {
            pylsp = {
                configurationSources = { "flake8" },
            },
        }
        pylsp_venv.setup { server = { on_attach = on_attach, settings = settings } }

        assert.stub(pylsp.setup).called_with(match.table_containing {
            on_attach = on_attach,
            settings = settings,
        })
    end)

    it("SHOULD set on_new_config callback", function()
        pylsp_venv.setup()

        assert.stub(pylsp.setup).called_with(match.table_with_key "on_new_config")
    end)

    it("SHOULD only add on_new_config setting", function()
        local on_attach = function() end
        local settings = { pylsp = {} }
        pylsp_venv.setup { server = { on_attach = on_attach, settings = settings } }

        assert.stub(pylsp.setup).called_with(match.table_with_exact_keys { "on_attach", "settings", "on_new_config" })
    end)

    describe("User config validation", function()
        describe("server config validation", function()
            it("SHOULD error on number server config", function()
                assert.has_error(function()
                    pylsp_venv.setup { server = 1 }
                end)
            end)
            it("SHOULD error on string server config", function()
                assert.has_error(function()
                    pylsp_venv.setup { server = "server" }
                end)
            end)
            it("SHOULD error on function server config", function()
                assert.has_error(function()
                    pylsp_venv.setup {
                        server = function() end,
                    }
                end)
            end)
            it("SHOULD error on boolean server config", function()
                assert.has_error(function()
                    pylsp_venv.setup { server = false }
                end)
            end)
            it("SHOULD accept table server config", function()
                assert.has_no_error(function()
                    pylsp_venv.setup { server = {} }
                end)
            end)
            it("SHOULD accept nil server config", function()
                assert.has_no_error(function()
                    pylsp_venv.setup { server = nil }
                end)
            end)
        end)

        describe("virtualenv_finders config validation", function()
            it("SHOULD error on number virtualenv_finders config", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = 1 }
                end)
            end)
            it("SHOULD error on string virtualenv_finders config", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = "server" }
                end)
            end)
            it("SHOULD error on function virtualenv_finders config", function()
                assert.has_error(function()
                    pylsp_venv.setup {
                        virtualenv_finders = function() end,
                    }
                end)
            end)
            it("SHOULD error on boolean virtualenv_finders config", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = false }
                end)
            end)
            it("SHOULD error on empty table virtualenv_finders config", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = {} }
                end)
            end)
            it("SHOULD accept nil virtualenv_finders config", function()
                assert.has_no_error(function()
                    pylsp_venv.setup { virtualenv_finders = nil }
                end)
            end)

            it("SHOULD error on number virtualenv_finder", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = { 1 } }
                end)
            end)
            it("SHOULD error on string virtualenv_finder", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = { "server" } }
                end)
            end)
            it("SHOULD error on function virtualenv_finder", function()
                assert.has_error(function()
                    pylsp_venv.setup {
                        virtualenv_finders = {
                            function() end,
                        },
                    }
                end)
            end)
            it("SHOULD error on boolean virtualenv_finder", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = { false } }
                end)
            end)
            it("SHOULD error on virtualenv_finder without 'find'", function()
                assert.has_error(function()
                    pylsp_venv.setup { virtualenv_finders = { { foo = "bar" } } }
                end)
            end)
            it("SHOULD accept a valid virtualenv finder", function()
                assert.has_no_error(function()
                    pylsp_venv.setup {
                        virtualenv_finders = { { find = function() end } },
                    }
                end)
            end)
        end)

        describe("pylsp_plugin_configurators validation", function()
            it("SHOULD error on number pylsp_plugin_configurators", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = 1 }
                end)
            end)
            it("SHOULD error on string pylsp_plugin_configurators config", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = "server" }
                end)
            end)
            it("SHOULD error on function pylsp_plugin_configurators config", function()
                assert.has_error(function()
                    pylsp_venv.setup {
                        pylsp_plugin_configurators = function() end,
                    }
                end)
            end)
            it("SHOULD error on boolean pylsp_plugin_configurators config", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = false }
                end)
            end)
            it("SHOULD error on empty table pylsp_plugin_configurators config", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = {} }
                end)
            end)
            it("SHOULD accept nil pylsp_plugin_configurators config", function()
                assert.has_no_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = nil }
                end)
            end)

            it("SHOULD error on number pylsp_plugin_configurator", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = { 1 } }
                end)
            end)
            it("SHOULD error on string pylsp_plugin_configurator", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = { "server" } }
                end)
            end)
            it("SHOULD error on function pylsp_plugin_configurator", function()
                assert.has_error(function()
                    pylsp_venv.setup {
                        pylsp_plugin_configurators = {
                            function() end,
                        },
                    }
                end)
            end)
            it("SHOULD error on boolean pylsp_plugin_configurator", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = { false } }
                end)
            end)
            it("SHOULD error on pylsp_plugin_configurator without 'plugin'", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = { { configure_venv = function() end } } }
                end)
            end)
            it("SHOULD error on pylsp_plugin_configurator without 'configure_venv'", function()
                assert.has_error(function()
                    pylsp_venv.setup { pylsp_plugin_configurators = { { plugin = "foo" } } }
                end)
            end)
            it("SHOULD accept a valid plugin configurator", function()
                assert.has_no_error(function()
                    pylsp_venv.setup {
                        pylsp_plugin_configurators = {
                            { plugin = "foo", configure_venv = function() end },
                        },
                    }
                end)
            end)
        end)
    end)
end)
