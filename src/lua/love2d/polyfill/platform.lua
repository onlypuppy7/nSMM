--compatability: unchecked
--tested: no

platform = {
    apiLevel = '1.5',
    hw = function()
        return 3
    end,
    isColorDisplay = function()
        return true
    end,
    isDeviceModeRendering = function()
        return true
    end,
    isTabletModeRendering = function()
        return false
    end,
    errorHandler = false,
    registerErrorHandler = function(func)
        --setting to true will make errors ignored, func will be called with the error message
        platform.errorHandler = func
    end,
    withGC = function(func, ...)
        local gc = nil
        --todo
        func(..., gc)
    end,
    getDeviceID = function()
        return "nsmm-pc"
    end,

    window = {
        height = function ()
            if __DS then
                return love.graphics.getHeight()
            else
                return __PC.nativeHeight
            end
        end,
        width = function ()
            if __DS then
                return love.graphics.getWidth()
            else
                return __PC.nativeWidth
            end
        end,
        invalidate = function(x, y, w, h)
	        platform.window.invalidated	= true

            if x and y and w and h then
                x=x-1
                y=y-1
                w=w+2
                h=h+2
                if type(platform.window.invaliddata) == "table" then
                    local id	= platform.window.invaliddata
                    local xo, yo, wo, ho	= id[1], id[2],id[3],id[4]
                    local xn	= math.min(x, xo)
                    local yn	= math.min(y, yo)
                    local wn	= math.max(x+w, xo+wo) - xn + 2
                    local hn	= math.max(y+h, yo+ho) - yn + 2
                    
                    platform.window.invaliddata	= {xn, yn, wn, hn}
                else
                    platform.window.invaliddata	= {x, y, w, h}
                end
            else
                platform.window.invaliddata	= 0
            end
        end,
        backgroundColor = {255, 255, 255},
        setBackgroundColor = function(r, g, b)
            platform.window.backgroundColor = {r, g, b}
        end,
        getScrollHeight = function()
            return 0
        end,
        setScrollHeight = function(height)
        end,
        displayInvalidatedRectangles = function(bool)
        end,
    },
}