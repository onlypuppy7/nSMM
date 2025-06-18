local noop = {} -- the universal no-op object

-- meta for no-op behavior
local mt = {
    __index = function() return noop end,    -- obj.anything returns noop
    __call = function() return noop end,     -- obj() returns noop
    __newindex = function() end,             -- obj.anything = something does nothing
    __tostring = function() return "noop" end
}

setmetatable(noop, mt)

return noop