describe("pylsp_mypy configurator", function()
    local venv, configurator

    setup(function()
        configurator = require "pylsp_venv.configurators.pylsp_mypy"
    end)

    teardown(function()
        configurator = nil
    end)

    before_each(function()
        venv = {
            name = "test_venv",
            path = "/foo/test_venv",
            python_exe = "/foo/test_venv/bin/python",
        }
    end)

    it("SHOULD identify the plugin as pylsp_mypy", function()
        assert.are.equal("pylsp_mypy", configurator.plugin)
    end)

    it("SHOULD configure mypy python executable", function()
        local config = {}
        configurator.configure_venv(config, venv)
        assert.are.same({ overrides = { true, "--python-executable", "/foo/test_venv/bin/python" } }, config)
    end)

    it("SHOULD preserve existing overrides", function()
        local config = { overrides = { "--ignore-missing-imports" } }
        configurator.configure_venv(config, venv)
        assert.are.same({
            overrides = {
                "--ignore-missing-imports",
                "--python-executable",
                "/foo/test_venv/bin/python",
            },
        }, config)
    end)

    it("SHOULD not override existing python executable", function()
        local config = { overrides = { "--python-executable", "/some/venv/bin/python" } }
        configurator.configure_venv(config, venv)
        assert.are.same({ overrides = { "--python-executable", "/some/venv/bin/python" } }, config)
    end)

    it("SHOULD error on invalid venv parameter", function()
        assert.has_error(function()
            configurator.configure_venv({}, { name = "incomplete" })
        end)
    end)
end)
