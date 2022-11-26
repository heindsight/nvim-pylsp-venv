-- Find a local virtual environment in the directory.

local lsputil = require("lspconfig.util")

local P

function P.find(root_dir)
    for _, pattern in ipairs({ "*", ".*" }) do
        local match = vim.fn.glob(lsputil.path.join(root_dir, pattern, "pyvenv.cfg"))
        if match ~= "" then
            return lsputil.path.dirname(match)
        end
    end

    -- No virtual environment found.
    return nil
end

return P
