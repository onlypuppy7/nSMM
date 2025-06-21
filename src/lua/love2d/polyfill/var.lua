--compatability: partial, no monitor, saves immediately to json file instead of marking as changed
--tested: yes

local json = require("love2d.libs.dkjson")

local VARS_FILENAME = "vars.json"
local variables = {}

local function loadVars()
    if love.filesystem.getInfo and love.filesystem.getInfo(VARS_FILENAME) then
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
    if love.filesystem.getInfo and love.filesystem.write then
        local contents = json.encode(variables)
        love.filesystem.write(VARS_FILENAME, contents)
    end
end

var = {
    -- returns list of variable names
    list = function()
        local names = {}
        for k in pairs(variables) do
            table.insert(names, k)
        end
        return names
    end,
    -- create empty numeric list
    makeNumericList = function(name)
        variables[name] = {}
        saveVars()
        return nil -- success
    end,
    -- recall value by name
    recall = function (name)
        local v = variables[name]
        if v == nil then
            return nil, "Variable not found"
        end
        -- return value as-is, compatible types only
        return v
    end,
    -- recall a single cell (1-based index) from list or matrix
    recallAt = function (name, col, row)
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
    end,
    -- recall variable as string
    recallStr = function(name)
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
    end,
    -- store a value by name
    store = function (name, value)
        -- optionally add checks on value type here
        variables[name] = value
        saveVars()
        return nil -- success
    end,
    -- store a numeric value at list/matrix position
    storeAt = function (name, numericValue, col, row)
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
    end,

    
    monitor = function(name)
        return 0 -- success
    end,
    unmonitor = function(name)
    end,
}

loadVars()



--test suite for var library
--[[
local tests = {}
local results = {}

-- Helpers
local function recordResult(name, passed, message)
    local status = passed and "[PASS]" or "[FAIL]"
    local out = status .. " " .. name
    if message and message ~= "" then
        out = out .. " - " .. message
    end
    print(out)
end

-- Test 1: var.store and var.recall (real number)
tests[#tests+1] = function()
    local name = "test_real"
    local value = 3.14
    local err = var.store(name, value)
    local recalled = var.recall(name)
    recordResult("store/recall (real)", recalled == value, "Expected "..value.." but got "..tostring(recalled)..(err and " Error: "..err or ""))
end

-- Test 2: var.store and var.recallStr
tests[#tests+1] = function()
    local name = "test_str"
    local value = 42
    var.store(name, value)
    local recalledStr = var.recallStr(name)
    recordResult("recallStr", recalledStr == "42", "Expected '42' but got "..tostring(recalledStr))
end

-- Test 3: var.makeNumericList + var.storeAt + var.recallAt
tests[#tests+1] = function()
    local name = "numList"
    var.makeNumericList(name)
    var.storeAt(name, 9.81, 1)
    local recalled = var.recallAt(name, 1)
    recordResult("makeNumericList/storeAt/recallAt (list)", recalled == 9.81, "Expected 9.81 but got "..tostring(recalled))
end

-- Test 4: Matrix store and recallAt
tests[#tests+1] = function()
    local name = "mat"
    var.store(name, {{1, 2}, {3, 4}})
    var.storeAt(name, 13.3, 1, 1)
    local val = var.recallAt(name, 1, 1)
    recordResult("storeAt/recallAt (matrix)", val == 13.3, "Expected 13.3 but got "..tostring(val))
end

-- Test 5: var.list
tests[#tests+1] = function()
    local list = var.list()
    local hasTestReal = false
    for _, v in ipairs(list) do
        if v == "test_real" then
            hasTestReal = true
            break
        end
    end
    recordResult("var.list", hasTestReal, "Variable 'test_real' not found in var.list")
end

-- Test 6: monitor/unmonitor
tests[#tests+1] = function()
    local name = "monTest"
    var.store(name, 5)
    local mon = var.monitor(name)
    var.unmonitor(name)
    recordResult("monitor/unmonitor", mon == 0, "monitor returned "..tostring(mon))
end

-- Run all tests
function runTests()
    print("=== Running Variable Library Tests ===")
    for i, test in ipairs(tests) do
        local ok, err = pcall(test)
        if not ok then
            recordResult("Test #" .. i .. " crashed", false, err)
        end
    end
    print("=== Test Run Complete ===")
end

-- Auto-run on script start
runTests()
]]--