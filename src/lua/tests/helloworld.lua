function love.draw(screen)
    love.graphics.print("Hello World!", 20, 20)
end

function love.gamepadpressed(joystick, button)
    love.event.quit()
end