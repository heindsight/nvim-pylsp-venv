describe("virtualenvwrapper finder", function()
    local cwd
    local finder
    local old_home
    local old_workon_home

    setup(function()
        local lfs = require "lfs"
        cwd = lfs.currentdir()
        finder = require "pylsp_venv.finders.virtualenvwrapper"
    end)

    teardown(function()
        finder = nil
        cwd = nil
    end)

    before_each(function()
        old_home = vim.env.HOME
        old_workon_home = vim.env.WORKON_HOME
        vim.env.HOME = cwd .. "/fixtures/data/home/test"
        vim.env.WORKON_HOME = ""
    end)

    after_each(function()
        vim.env.HOME = old_home
        vim.env.WORKON_HOME = old_workon_home
    end)

    it("SHOULD find project venv", function()
        local venv = finder.find "/test/project"
        assert.are.same({
            name = "venv_project",
            path = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_project",
            python_exe = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_project/bin/python",
        }, venv)
    end)

    it("SHOULD return nil if no venv found", function()
        local venv = finder.find "/other/project"
        assert.is_nil(venv)
    end)

    it("SHOULD find alphabetically first venv", function()
        local venv = finder.find "/test/project/alphabet"
        assert.are.same({
            name = "venv_a",
            path = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_a",
            python_exe = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_a/bin/python",
        }, venv)
    end)

    it("SHOULD find windows venv", function()
        local venv = finder.find "/test/project/win"
        assert.are.same({
            name = "venv_win",
            path = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_win",
            python_exe = cwd .. "/fixtures/data/home/test/.virtualenvs/venv_win/Scripts/python.exe",
        }, venv)
    end)

    it("SHOULD respect WORKON_HOME env var", function()
        vim.env.WORKON_HOME = cwd .. "/fixtures/data/virtualenvwrapper"
        local venv = finder.find "/test/project"
        assert.are.same({
            name = "some_venv",
            path = cwd .. "/fixtures/data/virtualenvwrapper/some_venv",
            python_exe = cwd .. "/fixtures/data/virtualenvwrapper/some_venv/bin/python",
        }, venv)
    end)
end)
