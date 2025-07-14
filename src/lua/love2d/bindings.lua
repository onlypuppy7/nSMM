local console = require("love2d.console.console")

__PC.nativeWidth = 318
__PC.nativeHeight = 212
__PC.scale = __PC.console and 1 or 2

function love.load()
    if (not __DS) and (not __PC.console) then
        love.graphics.setDefaultFilter("nearest", "nearest")

        local iconData = love.image.newImageData("love2d/icon.png")
        love.window.setIcon(iconData)

        love.window.setMode(__PC.nativeWidth * __PC.scale, __PC.nativeHeight * __PC.scale)
        gameCanvas = love.graphics.newCanvas(__PC.nativeWidth, __PC.nativeHeight)
    end

    __PC.onEvents.load()
end

local targetFPS = 30
local targetDt = 1 / targetFPS
local maxDt = 0.25
local accumulator = 0
gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
if not __DS then gameCanvas:setFilter("nearest", "nearest") end

function love.draw()
    local dt = math.min(love.timer.getDelta(), maxDt)
    accumulator = accumulator + dt

    if accumulator >= targetDt then
        accumulator = accumulator - targetDt

        love.graphics.setCanvas(gameCanvas)
        love.graphics.clear()

        __PC.loop()
        
        love.graphics.setCanvas()
    end
        
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(gameCanvas, 0, 0, 0, __PC.scale, __PC.scale)

    console.draw()
    love.timer.step()
end

function love.textinput(text)
    if not console.isEnabled() then __PC.onEvents.textinput(text) end
    console.textinput(text)
end

local receiving = false
local base32_buffer = ""
local BASE32_ALPHABET = {}
for i, c in ipairs({
    "A","B","C","D","E","F","G","H","I","J","K","L","M",
    "N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
    "2","3","4","5","6","7"
}) do
    BASE32_ALPHABET[c] = i - 1
end

local function to_binary(n, bits)
    local t = {}
    for i = bits, 1, -1 do
        t[#t+1] = (n % 2 == 1) and '1' or '0'
        n = math.floor(n / 2)
    end
    return table.concat(t):reverse()
end

local function base32_decode(str)
    local bits = ""
    for c in str:gmatch(".") do
        local val = BASE32_ALPHABET[c]
        if val == nil then return nil end
        bits = bits .. to_binary(val, 5)
    end

    local out = {}
    for i = 1, #bits, 8 do
        local byte = bits:sub(i, i+7)
        if #byte == 8 then
            table.insert(out, string.char(tonumber(byte, 2)))
        end
    end

    return table.concat(out)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f15" then
        if not receiving then
            receiving = true
            base32_buffer = ""
        else
            receiving = false
            local decoded = base32_decode(base32_buffer)
            if decoded then
                __PC.handleDecodedInput(decoded)
            end
        end
    elseif receiving then
        key = key:upper()
        if BASE32_ALPHABET[key] then
            base32_buffer = base32_buffer .. key
        end
    elseif not console.isEnabled() and not __PC.ToolPalette:bindings("keypressed", key, scancode, isrepeat) then
        __PC.onEvents.keypressed(key, scancode, isrepeat)
    end
    console.keypressed(key, scancode, isrepeat)
end


function love.keyreleased(key, scancode, isrepeat)
    if not console.isEnabled() and not __PC.ToolPalette:bindings("keyreleased", key, scancode, isrepeat) then
        __PC.onEvents.keyreleased(key, scancode, isrepeat)
    end
end

function love.mousepressed(x, y, button)
    if not console.isEnabled() and not __PC.ToolPalette:bindings("mousepressed", x / __PC.scale, y / __PC.scale, button) then
        __PC.onEvents.mousepressed(x / __PC.scale, y / __PC.scale, button)
    end
end

function love.focus(f)
    __PC.onEvents.focus(f)
end

function love.mousereleased(x, y, button)
    if not console.isEnabled() and not __PC.ToolPalette:bindings("mousereleased", x / __PC.scale, y / __PC.scale, button) then
        __PC.onEvents.mousereleased(x / __PC.scale, y / __PC.scale, button)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not console.isEnabled() and not __PC.ToolPalette:bindings("mousemoved", x / __PC.scale, y / __PC.scale, dx / __PC.scale, dy / __PC.scale, istouch) then
        __PC.onEvents.mousemoved(x / __PC.scale, y / __PC.scale, dx / __PC.scale, dy / __PC.scale, istouch)
    end
end

function love.quit()
    __PC.onEvents.quit()
end

function love.wheelmoved(x, y)
    __PC.onEvents.wheelmoved(x, y)
end