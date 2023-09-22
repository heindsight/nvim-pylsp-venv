local assert = require "luassert"
local assert_util = require "luassert.util"

-- Match an argument table that is a superset of the given table.
local function table_containing(_, arguments)
    local expected = arguments[1]

    return function(value)
        if type(value) ~= "table" then
            return false
        end

        for expected_key, expected_val in pairs(expected) do
            if not assert_util.deepcompare(value[expected_key], expected_val) then
                return false
            end
        end

        return true
    end
end

assert:register("matcher", "table_containing", table_containing)

-- Match an argument table containing the given key
local function table_with_key(_, arguments)
    local expected = arguments[1]

    return function(value)
        for key, _ in pairs(value) do
            if key == expected then
                return true
            end
        end
        return false
    end
end

assert:register("matcher", "table_with_key", table_with_key)

-- Match an argument table with exactly the given set of keys
local function table_with_exact_keys(_, arguments)
    local expected = {}

    for _, key in ipairs(arguments[1]) do
        expected[key] = true
    end

    return function(value)
        local keys = {}
        for key, _ in pairs(value) do
            keys[key] = true
        end
        return assert_util.deepcompare(expected, keys)
    end
end

assert:register("matcher", "table_with_exact_keys", table_with_exact_keys)
