local json = require("libs.dkjson")

local VARS_FILENAME = "vars.json"
local variables = {}

local function loadVars()
    if love.filesystem.getInfo(VARS_FILENAME) then
        local contents = love.filesystem.read(VARS_FILENAME)
        local tbl, _, err = json.decode(contents)
        if not err and type(tbl) == "table" then
            variables = tbl
        else
            variables = {}
        end
    else
        variables = {}
    end
end

local function saveVars()
    local contents = json.encode(variables)
    love.filesystem.write(VARS_FILENAME, contents)
end

var = {}

-- returns list of variable names
function var.list()
    local names = {}
    for k in pairs(variables) do
        table.insert(names, k)
    end
    return names
end

-- create empty numeric list
function var.makeNumericList(name)
    variables[name] = {}
    saveVars()
    return nil -- success
end

-- monitor / unmonitor stubs (no real monitoring in this polyfill)
function var.monitor(name)
    -- stub: could add callback registration here if you want
    return 0 -- success
end

function var.unmonitor(name)
    return 0 -- success
end

-- recall value by name
function var.recall(name)
    local v = variables[name]
    if v == nil then
        return nil, "Variable not found"
    end
    -- return value as-is, compatible types only
    return v
end

-- recall a single cell (1-based index) from list or matrix
function var.recallAt(name, col, row)
    local tbl = variables[name]
    if not tbl then
        return nil, "Variable not found"
    end
    row = row or 1
    if type(tbl) ~= "table" then
        return nil, "Variable is not a list or matrix"
    end
    local rowtbl = tbl[row]
    if type(rowtbl) == "table" then
        -- matrix
        local val = rowtbl[col]
        if type(val) == "number" then
            return val
        else
            return nil, "Cell value is not numeric"
        end
    else
        -- list
        local val = tbl[col]
        if type(val) == "number" then
            return val
        else
            return nil, "Cell value is not numeric"
        end
    end
end

-- recall variable as string
function var.recallStr(name)
    local v = variables[name]
    if v == nil then
        return nil, "Variable not found"
    end
    local s, err = pcall(function() return json.encode(v) end)
    if s then
        return json.encode(v)
    else
        return nil, "Cannot recall as string"
    end
end

-- store a value by name
function var.store(name, value)
    -- optionally add checks on value type here
    variables[name] = value
    saveVars()
    return nil -- success
end

-- store a numeric value at list/matrix position
function var.storeAt(name, numericValue, col, row)
    if type(numericValue) ~= "number" then
        return "cannot store: value not numeric"
    end
    local tbl = variables[name]
    if not tbl then
        return "cannot store: variable not found"
    end
    row = row or 1
    if type(tbl) ~= "table" then
        return "cannot store: variable is not a list or matrix"
    end
    if row == 1 then
        -- list
        if col == #tbl + 1 then
            -- append
            tbl[col] = numericValue
        elseif col <= #tbl then
            tbl[col] = numericValue
        else
            return "cannot store: invalid index"
        end
    else
        -- matrix
        tbl[row] = tbl[row] or {}
        if col == #tbl[row] + 1 then
            tbl[row][col] = numericValue
        elseif col <= #tbl[row] then
            tbl[row][col] = numericValue
        else
            return "cannot store: invalid index"
        end
    end
    saveVars()
    return nil
end

loadVars()