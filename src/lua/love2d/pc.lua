__PC = {
    fontSupport = true,
    console = false,
    newImage = love.graphics.newImage,
}

-- print("love._console", love._console)
if love._console then
    __PC.fontSupport = false
    __PC.console = love._console
end

__PC.timeNow = function()
    return love.timer.getTime() * 1000
end

__PC.loop = function()
	local tm = __PC.timeNow()

	if timer.running and tm >= timer.delay + timer.lastrun then
		timer.lastrun	= tm
		__PC.callEvent("timer")
	end

	if platform.window.invalidated or __DS then
		local id	=	platform.window.invaliddata
        
		-- if id == 0 then
			love.graphics.clear()
		-- else
		-- 	love.graphics.setColor(1, 1, 1, 1)
		-- 	love.graphics.rectangle("fill", id[1], id[2],id[3],id[4])
		-- end
		
		platform.gc:default()
		__PC.callEvent("paint", platform.gc)
		platform.window.invalidated	= false
		platform.window.invaliddata	= 0
	
        __PC.ToolPalette:paint(platform.gc)
	    -- love.graphics.present()
	end

    __PC.callAllHeldKeys()
end