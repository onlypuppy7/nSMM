--compatability: unchecked
--tested: no

timer = {
    delay = 0,
    running = false,
    lastrun = 0,
    start = function(t)
        PCspire.debuginfo("starting timer")
        if love.timer then
            if t < 0.01 then error("argument needs to be >=0.01") end
            timer.delay = t
            timer.running = true
            timer.lastrun = love.timer.getMicroTime()
        else
            error("Timer not initialized! This is a problem with PCspire, not you!")
        end
    end,
    stop = function()
        timer.delay = 0
        timer.running = false
    end,
    getMilliSecCounter = function()
        return love.timer.getMicroTime() * 1000
    end
}
