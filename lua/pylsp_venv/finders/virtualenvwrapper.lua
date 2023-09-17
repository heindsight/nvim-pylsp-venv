-- Look for a virtualenvwrapper virtual environment with .project file pointing to the given root directory

local lsputil = require "lspconfig.util"

local util = require "pylsp_venv.util"

local P = {}

local function get_workon_home()
    local workon = vim.env.WORKON_HOME
    if not workon or workon == "" then
        workon = lsputil.path.join(vim.env.HOME, ".virtualenvs")
    end
    return vim.fs.normalize(workon)
end

function P.find(root_dir)
    local workon_home = get_workon_home()
    local venvs = util.find_virtual_environments(workon_home)

    for _, venv in ipairs(venvs) do
        local project_file = vim.fn.glob(lsputil.path.join(venv.path, ".project"), true, false)
        if project_file ~= "" then
            local lines = vim.fn.readfile(project_file, "", 1)
            if lines[1] == root_dir then
                return venv
            end
        end
    end

    -- No virtual environment found
    return nil
end

return P
