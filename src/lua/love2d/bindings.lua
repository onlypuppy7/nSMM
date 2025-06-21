local nativeWidth, nativeHeight = 318, 212
__PC.scale = 3

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")

    local iconData = love.image.newImageData("love2d/icon.png")
    love.window.setIcon(iconData)

    __PC.onEvents.load()
    love.window.setMode(nativeWidth * __PC.scale, nativeHeight * __PC.scale)
    gameCanvas = love.graphics.newCanvas(nativeWidth, nativeHeight)
end

local targetFPS = 30
local targetDt = 1 / targetFPS
local maxDt = 0.25
local accumulator = 0
local gameCanvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
gameCanvas:setFilter("nearest", "nearest")

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
end

function love.textinput(text)
    __PC.onEvents.textinput(text)
end

function love.keypressed(key, scancode, isrepeat)
    __PC.onEvents.keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode, isrepeat)
    __PC.onEvents.keyreleased(key, scancode, isrepeat)
end

function love.mousepressed(x, y, button)
    __PC.onEvents.mousepressed(x / __PC.scale, y / __PC.scale, button)
end

function love.focus(f)
    __PC.onEvents.focus(f)
end

function love.mousereleased(x, y, button)
    __PC.onEvents.mousereleased(x / __PC.scale, y / __PC.scale, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    __PC.onEvents.mousemoved(x / __PC.scale, y / __PC.scale, dx / __PC.scale, dy / __PC.scale, istouch)
end

function love.quit()
    __PC.onEvents.quit()
end

function love.wheelmoved(x, y)
    __PC.onEvents.wheelmoved(x, y)
end