-- Find a local virtual environment in the directory.

local lsputil = require("lspconfig.util")

local P

function P.find(root_dir)
    for _, pattern in ipairs({ "*", ".*" }) do
        local matches = vim.fn.glob(lsputil.path.join(root_dir, pattern, "pyvenv.cfg"), true, true)
        if !vim.tbl_isempty(matches) then
            return vim.fs.dirname(matches[1])
        end
    end

    -- No virtual environment found.
    return nil
end

return P
