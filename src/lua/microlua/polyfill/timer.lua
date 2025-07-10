love.timer = {}

local tmr = Timer.new()
tmr:start()

local lastTime = tmr:getTime()
local delta = 0

function love.timer.getTime()
    return tmr:getTime()
end

function love.timer.getDelta()
    return delta
end

--call this once per frame to update delta
function love.timer.step()
    local now = tmr:getTime()
    delta = now - lastTime
    lastTime = now
end