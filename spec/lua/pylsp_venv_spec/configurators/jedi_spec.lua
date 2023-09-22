describe("jedi configurator", function()
    local configurator, venv

    setup(function()
        configurator = require "pylsp_venv.configurators.jedi"
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

    it("SHOULD identify plugin as jedi", function()
        assert.are.equal("jedi", configurator.plugin)
    end)

    it("SHOULD configure jedi environment", function()
        local config = {}
        configurator.configure_venv(config, venv)
        assert.are.same({ environment = "/foo/test_venv" }, config)
    end)

    it("SHOULD not override existing environment setting", function()
        local config = { environment = "/some/venv" }
        configurator.configure_venv(config, venv)
        assert.are.same({ environment = "/some/venv" }, config)
    end)

    it("SHOULD error on invalid venv parameter", function()
        assert.has_error(function()
            configurator.configure_venv({}, { name = "incomplete" })
        end)
    end)
end)
