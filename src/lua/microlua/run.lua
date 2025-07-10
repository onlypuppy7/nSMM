love.load()

while not Keys.held.Start do
    Controls.read()

    love.draw()

    screen.print(SCREEN_DOWN, 0, 0, "Press START to quit", Color.new(31, 31, 31))
    render()
end