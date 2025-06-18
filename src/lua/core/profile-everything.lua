local function hookFunctions(libName, lib)
    local function hook(v, funcName)
        print("Hooking function: " .. funcName)
        local category = type(lib) == "table" and libName or "hooked"

        return Profiler:wrap(funcName, v, category)
    end

    if type(lib) == "table" then
        for k, v in pairs(lib) do
            local funcName = libName .. "." .. k
            if type(v) == "function" then
                lib[k] = hook(v, funcName)
            elseif type(v) == "table" then
                hookFunctions(libName .. "." .. k, v) -- recursive hook for nested tables
            end
        end
    elseif type(lib) == "function" then -- if the library is a function, we can wrap it directly
        lib = hook(lib, libName)
    end
end

if studentSoftware then
    hookFunctions("string", string)
    hookFunctions("table", table)
    hookFunctions("math", math)

    -- hookFunctions("unpack", unpack)
    hookFunctions("collectgarbage", collectgarbage)
    hookFunctions("print", print)
    hookFunctions("error", error)
    hookFunctions("type", type)
    hookFunctions("pairs", pairs)
    hookFunctions("ipairs", ipairs)
    hookFunctions("next", next)
    hookFunctions("tostring", tostring)
    hookFunctions("tonumber", tonumber)
    hookFunctions("assert", assert)
    hookFunctions("require", require)
    hookFunctions("pcall", pcall)
    hookFunctions("xpcall", xpcall)
end