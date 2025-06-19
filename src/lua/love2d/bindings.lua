local onEvents = require("polyfill.on")

function love.keypressed(key, scancode, isrepeat)
    onEvents.keypressed(key, scancode, isrepeat)
end

function love.load()
    onEvents.load()
end

function love.mousepressed(x, y, button)
    onEvents.mousepressed(x, y, button)
end

function love.focus(f)
    onEvents.focus(f)
end

function love.mousereleased(x, y, button)
    onEvents.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    onEvents.mousemoved(x, y, dx, dy, istouch)
end

function love.quit()
    onEvents.quit()
end