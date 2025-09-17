local consoleLib = false
require("love2d.controls.virtualcontrols")

if __PC.includeOnScreenConsole then
    consoleLib = require("love2d.console.console")
    consoleLib.textinput("~") --uncomment to start with console open
end

function love.load()
    if (not __DS) and (not __PC.consoleHW) then
        love.graphics.setDefaultFilter("nearest", "nearest")

        local iconData = love.image.newImageData("love2d/icon.png")
        love.window.setIcon(iconData)

        love.window.setMode((__PC.nativeWidth * __PC.scale) + __PC.screenPaddingX, (__PC.nativeHeight * __PC.scale) + __PC.screenPaddingY)
    end
    if (not __DS) and __PC.useGameCanvas then
        gameCanvas = love.graphics.newCanvas(__PC.nativeWidth, __PC.nativeHeight)
    end

    if __PC.includeTouchControls then
        VirtualControls:setup()
    end

    __PC.onEvents.load()
end

local targetFPS = 30
local targetDt = 1 / targetFPS
local maxDt = 0.25
local accumulator = 0
if (not __DS) and __PC.useGameCanvas then
    gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
end
if __PC.useGameCanvas then
    gameCanvas:setFilter("nearest", "nearest")
end

function love.draw(screen)
    -- screen = "top" --for testing

    if screen == "top" then
        -- if not (editor and editor.active) then return end

        --uncomment if canvases work

        -- if not topScreenCanvas then
        --     --screen: 800x240
        --     topScreenCanvas = love.graphics.newCanvas(800, 240)
        --     love.graphics.setCanvas(topScreenCanvas)
            
            love.graphics.clear(249, 0xd7/255, 0x3b/255, 1) -- set background color to #f9d73b

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 20-5, 20-5, 156+10, 58+10)

            love.graphics.setColor(1, 1, 1)
            --logo: 156x58
            nSMMLogo = nSMMLogo or love.graphics.newImage("love2d/nsmmlogo.t3x")
            love.graphics.draw(nSMMLogo, 20, 20)

            local boxX = 190
            local boxY = 5
            local boxW = 170
            local boxH = 230

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", boxX, boxY, boxW, boxH)

            gc:setColorRGB(0, 0, 0)
            gc:setFont("sansserif", "b", 12)
            gc:drawString("Controls:\nD-Pad\nL-Stick\nA\nB\nX\nY\nSelect\nStart\nTouch\nL/R\n\nR-Stick\nWhile Selecting:\nL\nR", boxX + 10, boxY + 10)
            gc:setFont("sansserif", "r", 12)
            -- gc:drawString("-   Move", boxX + 60, boxY + 33)
            gc:drawString("\n-   Move\n-   Move\n-   Jump/Click\n-   Fire/(-)\n-   Delete\n-   Toolpalette\n-   Cancel/Back\n-   Enter\n-   Place\n-   Make Selection\n    (While Touching)\n-   Move Cursor\n\n-   Copy\n-   Move", boxX + 60, boxY + 10)
            
            local creditBoxX = 20
            local creditBoxY = 100
            local creditBoxW = 156
            local creditBoxH = 40

            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", creditBoxX - 4, creditBoxY - 4, creditBoxW + 8, creditBoxH + 8)

            gc:setColorRGB(0, 0, 0)
            gc:setFont("sansserif", "r", 12)
            gc:drawString("Originally for TI-Nspire Calculator\nCreated by onlypuppy7\nPowered by LovePotion", creditBoxX, creditBoxY + 7)

        --     love.graphics.setCanvas()
        -- end
        -- love.graphics.setColor(1, 1, 1)
        -- love.graphics.draw(topScreenCanvas, 0, 0)
        return
    end

    if (not __DS) and __PC.useGameCanvas then
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
        love.graphics.draw(gameCanvas, __PC.screenOffsetX, __PC.screenOffsetY, 0, __PC.scale, __PC.scale)

        if consoleLib then consoleLib.draw() end
        if __PC.includeTouchControls then VirtualControls:draw() end
    else
        __PC.loop()
    end
    
    love.timer.step()
end

function love.textinput(text)
    print("textinput", text)
    if consoleLib then
        if not consoleLib.isEnabled() then __PC.onEvents.textinput(text) end
        consoleLib.textinput(text)
    else
        __PC.onEvents.textinput(text)
    end
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
    -- print("keypressed", key, scancode, isrepeat)
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
    elseif ((not consoleLib) or not consoleLib.isEnabled()) and not __PC.ToolPalette:bindings("keypressed", key, scancode, isrepeat) then
        __PC.onEvents.keypressed(key, scancode, isrepeat)
    end
    if consoleLib then
        consoleLib.keypressed(key, scancode, isrepeat)
    end
end


function love.keyreleased(key, scancode, isrepeat)
    if consoleLib and consoleLib.isEnabled() then return end
    if __PC.ToolPalette:bindings("keyreleased", key, scancode, isrepeat) then return end

    __PC.onEvents.keyreleased(key, scancode, isrepeat)
end

function love.focus(f)
    __PC.onEvents.focus(f)
end

function love.mousepressed(x, y, button, istouch, touches)
    if __PC.includeTouchControls and not (istouch == "touch") then return end

    __PC.cursorPos.x = (x - __PC.screenOffsetX) / __PC.scale
    __PC.cursorPos.y = (y - __PC.screenOffsetY) / __PC.scale

    -- if touches and touches > 1 then button = 2 end --this doesnt work actually lmfaoo
    -- print("mousepressed", button, istouch)

    if consoleLib and consoleLib.isEnabled() then return end
    if __PC.ToolPalette:bindings("mousepressed", __PC.cursorPos.x, __PC.cursorPos.y, button) then return end

    __PC.onEvents.mousepressed(__PC.cursorPos.x, __PC.cursorPos.y, button)
end

function love.mousereleased(x, y, button, istouch)
    if __PC.includeTouchControls and not (istouch == "touch") then return end

    __PC.cursorPos.x = (x - __PC.screenOffsetX) / __PC.scale
    __PC.cursorPos.y = (y - __PC.screenOffsetY) / __PC.scale

    print("mousereleased", button, istouch)

    if consoleLib and consoleLib.isEnabled() then return end
    if __PC.ToolPalette:bindings("mousereleased", __PC.cursorPos.x, __PC.cursorPos.y, button) then return end

    __PC.onEvents.mousereleased(__PC.cursorPos.x, __PC.cursorPos.y, button)
end

function love.mousemoved(x, y, dx, dy, istouch, isstick)
    if __PC.includeTouchControls and not (istouch == "touch" or isstick) then return end
    -- if __PC.includeTouchControls and (not isstick) and VirtualControls:touchmoved("mouse", x, y, dx, dy, 1) then return end

    if not (isstick) then
        x = (x - __PC.screenOffsetX) / __PC.scale
        y = (y - __PC.screenOffsetY) / __PC.scale
    end

    __PC.cursorPos.x = math.max(0, math.min(__PC.nativeWidth, x))
    __PC.cursorPos.y = math.max(0, math.min(__PC.nativeHeight, y))

    -- print("setting mousemoved", istouch, isstick)

    if consoleLib and consoleLib.isEnabled() then return end
    if __PC.ToolPalette:bindings("mousemoved", __PC.cursorPos.x, __PC.cursorPos.y, dx / __PC.scale, dy / __PC.scale, istouch) then return end

    __PC.onEvents.mousemoved(__PC.cursorPos.x, __PC.cursorPos.y, dx / __PC.scale, dy / __PC.scale, istouch)
end

local touchX, touchY = 0, 0
local touchRadius = 5
local acceptTouch = false

function __PC:getShoulderDown()
    local joysticks = love.joystick.getJoysticks()
    local first = joysticks[1]
    return first and first:isGamepadDown("leftshoulder", "rightshoulder")
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    if __PC.includeTouchControls and VirtualControls:touchpressed(id, x, y, dx, dy, pressure) then return end
    --important: dont scale x/y because thatll be done in love.mousepressed

    touchX, touchY = x, y
    acceptTouch = true

    love.mousepressed(x, y, __PC:getShoulderDown() and 2 or 1, "touch")
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    if __PC.includeTouchControls and VirtualControls:touchreleased(id, x, y, dx, dy, pressure) then return end
    --important: dont scale x/y because thatll be done in love.mousereleased

    if acceptTouch then
        love.mousereleased(x, y, __PC:getShoulderDown() and 2 or 1, "touch")
    end
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    if __PC.includeTouchControls and VirtualControls:touchmoved(id, x, y, dx, dy, pressure) then return end
    --important: dont scale x/y because thatll be done in love.mousemoved

    local distx = x - touchX
    local disty = y - touchY
    
    if acceptTouch and (distx * distx + disty * disty > touchRadius * touchRadius) then
        acceptTouch = false
    end
    love.mousemoved(x, y, dx, dy, "touch")
end

function love.gamepadpressed(joystick, button)
    -- print("love.gamepadpressed")
    -- print(joystick, button)
    love.keypressed("_"..button)
end

function love.gamepadreleased(joystick, button)
    -- print("love.gamepadreleased")
    -- print(joystick, button)
    love.keyreleased("_"..button)
end

local stickThreshold = 0.5
local previousStickState = {}

function love.update(dt)
    for _, joystick in ipairs(love.joystick.getJoysticks()) do
        local id = joystick:getID()
        previousStickState[id] = previousStickState[id] or { left = false, right = false, up = false, down = false }

        local x, y = joystick:getGamepadAxis("leftx"), joystick:getGamepadAxis("lefty")
        local state = previousStickState[id]

        -- LEFT
        if x < -stickThreshold then
            love.keypressed("_dpleft")
            state.left = true
        else
            if state.left then
                love.keyreleased("_dpleft")
                state.left = false
            end
        end

        -- RIGHT
        if x > stickThreshold then
            love.keypressed("_dpright")
            state.right = true
        else
            if state.right then
                love.keyreleased("_dpright")
                state.right = false
            end
        end

        -- DOWN
        if y < -stickThreshold then
            love.keypressed("_dpdown")
            state.down = true
        else
            if state.down then
                love.keyreleased("_dpdown")
                state.down = false
            end
        end

        -- UP
        if y > stickThreshold then
            love.keypressed("_dpup")
            state.up = true
        else
            if state.up then
                love.keyreleased("_dpup")
                state.up = false
            end
        end

        -- RIGHT STICK CURSOR CONTROL
        local rx, ry = joystick:getGamepadAxis("rightx"), joystick:getGamepadAxis("righty")

        ry = -ry

        --sensitivity: tweak this
        local speed = 7500

        local dx, dy = rx * speed * dt, ry * speed * dt
        if (math.abs(dx) >= 1) or (math.abs(dy) >= 1) then
            love.mousemoved(__PC.cursorPos.x + rx * speed * dt, __PC.cursorPos.y + ry * speed * dt, 0, 0, false, true)
        end
    end

    __PC.SOUND:update(dt)
end

function love.quit()
    __PC.onEvents.quit()
end

function love.wheelmoved(x, y)
    __PC.onEvents.wheelmoved(x, y)
end