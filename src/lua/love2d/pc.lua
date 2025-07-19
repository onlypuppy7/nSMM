__PC = {
    fontSupport = true,
    consoleHW = false,
    newImage = love.graphics.newImage,
    useGameCanvas = true,
    includeOnScreenConsole = true,
    noCloneSFX = false,
    supportsBGM = true,
    supportsPausing = true,
    supportsCursor = not not (love and love.mouse),
    emulateCursor = not (love and love.mouse),
    bgmFormat = "ogg",
    nativeWidth = 318, --calculator
    nativeHeight = 212,
    scale = 2,
}

print("love._console", love._console)
if love._console or __DS then
    __PC.fontSupport = false
    __PC.useGameCanvas = false
    __PC.includeOnScreenConsole = false
    __PC.scale = 1
    targetLogicFps = 30

    if love._console then
        __PC.consoleHW = string.lower(love._console)
        love.graphics.set3D(false)
    elseif __DS then
        __PC.consoleHW = "ds"
    end

    -- print(__PC.consoleHW)
    if __PC.consoleHW == "3ds" or __PC.consoleHW == "wii u" then
        __PC.nativeWidth = 320 --ive forgotten what exactly about this is "native" atp
        __PC.nativeHeight = 220
        __PC.noCloneSFX = true
        -- __PC.supportsBGM = false --Source:stop() crashes the system. great! but love.audio.stop works. even better!!
        __PC.supportsPausing = false --buuuuut love.audio.pause() crashes! yayyy
        __PC.bgmFormat = "wav" --ogg lags
    end
end


function __PC.showKeyboard()
    love.keyboard.setTextInput(true)
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

	if platform.window.invalidated or __DS or __PC.consoleHW then
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

        if __PC.consoleHW == "3ds" then
            gc:setColorRGB(0,0,0)
            gc:fillRect(0, 220, 320, 20)
        end

        __PC:simulatedCursorDraw()
	    -- love.graphics.present()
	end

    __PC.callAllHeldKeys()
end

-- __PC.logic = function()
	
-- end