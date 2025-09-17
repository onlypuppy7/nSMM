require("love2d.controls.virtualcontrols")

function love.load()
    love.window.setTitle("Virtual Joystick Demo")
    -- setup virtual controls with left/right stick positions
    VirtualControls:setup()
end

function love.update(dt)
    -- example: you could read virtual joystick values here
    local lx, ly = VirtualControls:getGamepadAxis("leftx"), VirtualControls:getGamepadAxis("lefty")
    local rx, ry = VirtualControls:getGamepadAxis("rightx"), VirtualControls:getGamepadAxis("righty")
    -- do something with lx, ly, rx, ry
end

function love.draw()
    -- show where the game area is
    local gameWidth, gameHeight = 318, 212
    local windowWidth, windowHeight = love.graphics.getDimensions()
    local scale = math.min(windowWidth / gameWidth, windowHeight / gameHeight)
    local realWidth, realHeight = gameWidth * scale, gameHeight * scale

    -- center horizontally and vertically
    local offsetX = (windowWidth - realWidth) / 2
    local offsetY = (windowHeight - realHeight) / 2

    love.graphics.setColor(0, 0, 1, 0.25)
    love.graphics.rectangle("fill", offsetX, offsetY, realWidth, realHeight)

    love.graphics.setColor(1, 1, 1)

    -- draw virtual sticks
    VirtualControls:draw()

    local leftx, lefty, rightx, righty = 0, 0, 0, 0

    for _, joystick in ipairs(love.joystick.getJoysticks()) do
        leftx, lefty = joystick:getGamepadAxis("leftx"), joystick:getGamepadAxis("lefty")
        rightx, righty = joystick:getGamepadAxis("rightx"), joystick:getGamepadAxis("righty")
    end

    -- print values for debugging
    love.graphics.print(string.format("Left Stick: X: %.2f Y: %.2f", 
        leftx, lefty), 10, 10)
    love.graphics.print(string.format("Right Stick: X: %.2f Y: %.2f", 
        rightx, righty), 10, 30)
end

-- touch handlers for mobile
function love.touchpressed(id, x, y, dx, dy, pressure)
    VirtualControls:touchpressed(id, x, y, dx, dy, pressure)
end

function love.touchmoved(id, x, y, dx, dy, pressure)
    VirtualControls:touchmoved(id, x, y, dx, dy, pressure)
end

function love.touchreleased(id, x, y, dx, dy, pressure)
    VirtualControls:touchreleased(id, x, y, dx, dy, pressure)
end

-- mouse fallback for desktop testing
function love.mousepressed(x, y, button)
    VirtualControls:touchpressed("mouse", x, y, 0, 0, 1)
end

function love.mousemoved(x, y, dx, dy)
    VirtualControls:touchmoved("mouse", x, y, dx, dy, 1)
end

function love.mousereleased(x, y, button)
    VirtualControls:touchreleased("mouse", x, y, 0, 0, 1)
end

function love.gamepadpressed(joystick, button)
    print("love.gamepadpressed", joystick, button)
end

function love.gamepadreleased(joystick, button)
    print("love.gamepadreleased", joystick, button)
end