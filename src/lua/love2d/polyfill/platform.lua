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
        return "pcspire"
    end,

    window = {
        height = 212,
        width = 318,
        invalidate = function()
            --todo
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