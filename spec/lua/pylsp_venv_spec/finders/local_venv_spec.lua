describe("local_venv finder", function()
    local cwd
    local finder

    setup(function()
        local lfs = require "lfs"
        cwd = lfs.currentdir()
        finder = require "pylsp_venv.finders.local_venv"
    end)

    teardown(function()
        finder = nil
        cwd = nil
    end)

    it("SHOULD find local venv", function()
        local venv = finder.find(cwd .. "/fixtures/data/projects/project_with_local_venv")
        assert.are.same({
            name = "venv",
            path = cwd .. "/fixtures/data/projects/project_with_local_venv/venv",
            python_exe = cwd .. "/fixtures/data/projects/project_with_local_venv/venv/bin/python",
        }, venv)
    end)

    it("SHOULD ignore broken venv", function()
        local venv = finder.find(cwd .. "/fixtures/data/projects/project_broken_local_venv")
        assert.is_nil(venv)
    end)

    it("SHOULD handle missing venv", function()
        local venv = finder.find(cwd .. "/fixtures/data/projects/project_no_local_venv")
        assert.is_nil(venv)
    end)

    it("SHOULD find alphabetically first venv", function()
        local venv = finder.find(cwd .. "/fixtures/data/projects/project_multi_local_venv")
        assert.are.same({
            name = "avenv",
            path = cwd .. "/fixtures/data/projects/project_multi_local_venv/avenv",
            python_exe = cwd .. "/fixtures/data/projects/project_multi_local_venv/avenv/bin/python",
        }, venv)
    end)

    it("SHOULD find windows venv", function()
        local venv = finder.find(cwd .. "/fixtures/data/projects/project_win_venv")
        assert.are.same({
            name = "venv",
            path = cwd .. "/fixtures/data/projects/project_win_venv/venv",
            python_exe = cwd .. "/fixtures/data/projects/project_win_venv/venv/Scripts/python.exe",
        }, venv)
    end)
end)
