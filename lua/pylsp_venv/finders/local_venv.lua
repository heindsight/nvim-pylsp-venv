-- Find a local virtual environment in the given directory.

local util = require "pylsp_venv.util"

local P = {}

function P.find(root_dir)
    local venvs = util.find_virtual_environments(root_dir)
    return venvs[1]
end

return P
