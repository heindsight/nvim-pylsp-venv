describe("pylsp_mypy configurator", function()
    local pylsp_mypy_configurator = require("pylsp_venv.configurators.pylsp_mypy")

    local venv = {
        name = "test_venv",
        path = "/foo/test_venv",
        python_exe = "/foo/test_venv/bin/python",
    }

    it("identifies the pylsp plugin", function()
        assert.are.equal("pylsp_mypy", pylsp_mypy_configurator.plugin)
    end)

    it("configures pylsp_mypy python executable", function()
        local config = {}
        pylsp_mypy_configurator.configure_venv(config, venv)
        assert.are.same(
            { overrides = { true, "--python-executable", "/foo/test_venv/bin/python" } },
            config
        )
    end)

    it("preserves existing overrides", function()
        local config = { overrides = { "--ignore-missing-imports" } }
        pylsp_mypy_configurator.configure_venv(config, venv)
        assert.are.same(
            {
                overrides = {
                    "--ignore-missing-imports",
                    "--python-executable",
                    "/foo/test_venv/bin/python"
                }
            },
            config
        )
    end)

    it("does nothing if python executable is already set", function()
        local config = { overrides = { "--python-executable", "/some/venv/bin/python" } }
        pylsp_mypy_configurator.configure_venv(config, venv)
        assert.are.same(
            { overrides = { "--python-executable", "/some/venv/bin/python" } },
            config
        )
    end)

    it("validates venv", function()
        assert.has_error(function() pylsp_mypy_configurator.configure_venv({}, { name = "incomplete" }) end)
    end)
end)
