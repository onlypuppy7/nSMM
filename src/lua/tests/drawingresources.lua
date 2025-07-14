local i=1

Brick=image.new("resources/Brick.png")

function on.paint(gc)
    i = (i or -1) + 1
    gc:drawImage(Brick, math.random(0,199), math.random(0,199))
    -- print(Brick:height(), Brick:width())
end

timer.start(0.2)
function on.timer()
    platform.window:invalidate() --refreshes screen
end