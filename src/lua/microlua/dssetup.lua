__DS = {
    nativeWidth = 256,
    nativeHeight = 192,
    scale = 1
}

local __LOADED = {}

--built in one is busted lmfao
function require(modname)
    if __LOADED[modname] then
        return __LOADED[modname]
    end

    local path = modname:gsub("%.", "/") .. ".lua"
    -- print("[require] loading: " .. path)

    local result = dofile(path)

    -- local ok, result = pcall(dofile, path)
    -- if not ok then
    --     error("require error: " .. tostring(result))
    -- end

    if result == nil then result = true end
    __LOADED[modname] = result
    return result
end

function print(...) Debug.print(...) end --printing opens a whole prompt on the emulator (????)