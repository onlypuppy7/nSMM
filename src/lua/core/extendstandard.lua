function extendStandard()
    function math.clamp(x, minVal, maxVal)
        if x < minVal then return minVal end
        if x > maxVal then return maxVal end
        return x
    end

    function math.choice(t)
        return t[math.random(#t)]
    end

    function math.round(x, dp)
        dp = dp or 0
        local mult = 10 ^ dp
        return math.floor(x * mult + 0.5) / mult
    end

    function string.startsWith(str, prefix)
        return str:sub(1, #prefix) == prefix
    end

    function string.endsWith(str, suffix)
        return suffix == "" or str:sub(-#suffix) == suffix
    end

    function string.includes(str, substr)
        return str:find(substr, 1, true) ~= nil
    end

    --although i found out that nspire has it built in, it isnt compatible with the outputs from this function so im keeping it
    function string.split(input, char)
        local output={}
        if not input then return output end
        for str in string.gmatch(input, "([^"..char.."]+)") do
            table.insert(output, str)
        end return output
    end

    function string.trim(str)
        return str:match("^%s*(.-)%s*$")
    end

    function string.replaceAll(str, search, replace)
        local escapedSearch = search:gsub("([^%w])", "%%%1")
        return (str:gsub(escapedSearch, replace))
    end

    function string.padStart(str, targetLength, padStr)
        padStr = padStr or " "
        local needed = targetLength - #str
        if needed <= 0 then return str end
        local repeatCount = math.ceil(needed / #padStr)
        local padding = padStr:rep(repeatCount):sub(1, needed)
        return padding .. str
    end

    function string.padEnd(str, targetLength, padStr)
        padStr = padStr or " "
        local needed = targetLength - #str
        if needed <= 0 then return str end
        local repeatCount = math.ceil(needed / #padStr)
        local padding = padStr:rep(repeatCount):sub(1, needed)
        return str .. padding
    end

    function string.isEmpty(str)
        return str == nil or str == ""
    end

    function string.isAlpha(str) --only letters
        return not str:match("%W") and not str:match("%d")
    end

    function string.isNumeric(str) --only numbers
        return not str:match("%D") and not str:match("%s")
    end

    function string.isAlphaNumeric(str) --only letters, numbers and spaces
        return not str:match("%W")
    end

    function string.isInteger(str) --only integers
        return not str:match("%D") and not str:match("%s") and not str:match("^%d+%.%d+$")
    end

    local base64="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    function string.base64ToOctal(base64Char)
        return string.sub(string.format("%03o",string.find(base64,base64Char)-1),2,3)
    end

    function string.octalToBase64(octalPair)
        octalPair=tonumber(octalPair,8)
        return string.sub(base64,octalPair+1,octalPair+1)
    end

    getmetatable("").__index = string

    --of note: table stuff cant be called via table:method(args) due to limitations on the nspire lua so use table.method(table, args) instead

    function table.merge(...) --merge multiple tables
        local function merge(t1,t2)
            for k,v in pairs(t2 or {}) do
                if (type(v)=="table") and (type(t1[k] or false)=="table") then
                    merge(t1[k],t2[k])
                else t1[k]=v end
            end return t1
        end

        local t1={}
        for i=1,select("#",...) do
            local t2=select(i,...)
            if type(t2)=="table" then
                t1=merge(t1,t2)
            else error("Argument "..i.." is not a table") end
        end return t1
    end

    function table.apply(t1, t2)
        for k, v in pairs(t2) do
            if type(v) == "table" and type(t1[k] or false) == "table" then
                table.apply(t1[k], v)
            else
                t1[k] = v
            end
        end
    end

    function table.checkForValue(table, checkFor) --arg1: table of booleans arg2: boolean to look for. returns true if all are the same as checkFor
        for _, v in pairs(table) do
            if checkFor then if not v then return false end
            else             if v then     return false end
            end
        end return true
    end
end

extendStandard()