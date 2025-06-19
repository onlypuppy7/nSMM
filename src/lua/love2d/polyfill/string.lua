function string.split(s, sep)
    local output={}
    if not input then return output end
    for str in string.gmatch(input, "([^"..char.."]+)") do
        table.insert(output, str)
    end return output
end

function string.uchar(...) --written by ai because idk
    local chars = {}

    local function encode_utf8(cp)
        if cp <= 0x7F then
            return string.char(cp)
        elseif cp <= 0x7FF then
            local b1 = 0xC0 + math.floor(cp / 0x40)
            local b2 = 0x80 + (cp % 0x40)
            return string.char(b1, b2)
        elseif cp <= 0xFFFF then
            local b1 = 0xE0 + math.floor(cp / 0x1000)
            local b2 = 0x80 + (math.floor(cp / 0x40) % 0x40)
            local b3 = 0x80 + (cp % 0x40)
            return string.char(b1, b2, b3)
        elseif cp <= 0x10FFFF then
            local b1 = 0xF0 + math.floor(cp / 0x40000)
            local b2 = 0x80 + (math.floor(cp / 0x1000) % 0x40)
            local b3 = 0x80 + (math.floor(cp / 0x40) % 0x40)
            local b4 = 0x80 + (cp % 0x40)
            return string.char(b1, b2, b3, b4)
        else
            error(string.format("Invalid Unicode codepoint: 0x%X", cp))
        end
    end

    for i = 1, select("#", ...) do
        local cp = select(i, ...)
        if type(cp) ~= "number" or cp < 0 then
            error("Codepoints must be non-negative numbers")
        end
        chars[#chars+1] = encode_utf8(cp)
    end

    return table.concat(chars)
end

local function utf8_iter(s)
    local pos = 1
    local len = #s

    return function()
        if pos > len then return nil end
        local b = string.byte(s, pos)

        local char_len
        if b < 0x80 then
            char_len = 1
        elseif b >= 0xC0 and b < 0xE0 then
            char_len = 2
        elseif b >= 0xE0 and b < 0xF0 then
            char_len = 3
        elseif b >= 0xF0 and b < 0xF8 then
            char_len = 4
        else
            error("Invalid UTF-8 encoding at position " .. pos)
        end

        local char = string.sub(s, pos, pos + char_len - 1)
        pos = pos + char_len
        return char
    end
end

function string.usub(s, startpos, endpos) --written by ai because idk
    if type(s) ~= "string" then error("string expected") end
    startpos = startpos or 1
    endpos = endpos or -1

    -- Collect UTF-8 characters into a table
    local chars = {}
    for c in utf8_iter(s) do
        chars[#chars+1] = c
    end

    local len = #chars

    -- Handle negative indices
    if startpos < 0 then startpos = len + startpos + 1 end
    if endpos < 0 then endpos = len + endpos + 1 end

    -- Clamp to valid range
    if startpos < 1 then startpos = 1 end
    if endpos > len then endpos = len end
    if startpos > endpos then return "" end

    -- Concatenate the UTF-8 chars for substring
    local result_chars = {}
    for i = startpos, endpos do
        result_chars[#result_chars+1] = chars[i]
    end

    return table.concat(result_chars)
end

--these functions are for bluetooth stuff but theyre too complicated for me to add for almost no reason
function string.pack(type, ...)
end
function string.unpack(type, characteristicValue)
end

--[[
--uchar tests

-- ASCII: U+41 'A'
assert(string.uchar(0x41) == "A")

-- Latin small letter e with acute: U+00E9
assert(string.uchar(0xE9) == "\195\169")

-- Euro sign: U+20AC
assert(string.uchar(0x20AC) == "\226\130\172")

--alert: these tests work with this polyfill but not in the original ti nspire lmao
-- -- Smiling face emoji: U+1F600
-- assert(string.uchar(0x1F600) == "\240\159\152\128")

-- -- Multiple characters concatenated
-- local testStr = string.uchar(0x41, 0x20AC, 0x1F600)  -- "A€😀"
-- local expected = "A" .. "\226\130\172" .. "\240\159\152\128"
-- assert(testStr == expected)

print("All tests passed!")

--usub tests
local s = "aé𐍈😀" -- 'a', 'é' (2-byte), Gothic letter 𐍈 (4-byte), emoji 😀

assert(string.usub(s, 1, 1) == "a")
assert(string.usub(s, 2, 2) == "é")
assert(string.usub(s, 3, 3) == "𐍈")
assert(string.usub(s, 4, 4) == "😀")
assert(string.usub(s, 2, 4) == "é𐍈😀")
assert(string.usub(s, -2, -1) == "𐍈😀")
assert(string.usub(s, 1, -1) == s)

print("All string.usub tests passed!")
]]--