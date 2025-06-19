function love.keypressed(key, scancode, isrepeat)
    __PC.onEvents.keypressed(key, scancode, isrepeat)
end

function love.load()
    __PC.onEvents.load()
end

function love.mousepressed(x, y, button)
    __PC.onEvents.mousepressed(x, y, button)
end

function love.focus(f)
    __PC.onEvents.focus(f)
end

function love.mousereleased(x, y, button)
    __PC.onEvents.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
    __PC.onEvents.mousemoved(x, y, dx, dy, istouch)
end

function love.quit()
    __PC.onEvents.quit()
end

function love.draw()
    -- __PC.onEvents.update(dt)
    __PC.loop()
end