function noop()
    local noopObject = {} -- the universal no-op object

    -- meta for no-op behavior
    local mt = {
        __index = function() return noopObject end,    -- obj.anything returns noopObject
        __call = function() return noopObject end,     -- obj() returns noopObject
        __newindex = function() end,             -- obj.anything = something does nothing
        __tostring = function() return "noopObject" end
    }

    setmetatable(noopObject, mt)

    return noopObject
end