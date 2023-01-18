describe("jedi configurator", function()
    local jedi_configurator = require("pylsp_venv.configurators.jedi")

    local venv = {
        name = "test_venv",
        path = "/foo/test_venv",
        python_exe = "/foo/test_venv/bin/python",
    }

    it("identifies the pylsp plugin", function()
        assert.are.equal("jedi", jedi_configurator.plugin)
    end)

    it("configures jedi environment", function()
        local config = {}
        jedi_configurator.configure_venv(config, venv)
        assert.are.same({ environment = "/foo/test_venv" }, config)
    end)

    it("does nothing if environment is already set", function()
        local config = { environment = "/some/venv" }
        jedi_configurator.configure_venv(config, venv)
        assert.are.same({ environment = "/some/venv" }, config)
    end)

    it("validates venv", function()
        assert.has_error(function() jedi_configurator.configure_venv({}, { name = "incomplete" }) end)
    end)
end)
