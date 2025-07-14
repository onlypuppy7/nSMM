love.load()

local count = 0

while not Keys.held.Start do
    Controls.read()

    love.draw()

    count = count + 1

    screen.print(SCREEN_UP, 0, 0, "Press START to quit "..count, Color.new(31, 31, 31))
    render()
end