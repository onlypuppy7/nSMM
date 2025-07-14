fonts	= {}
fonts.r	= "love2d/ttf/TINSSaRG.TTF"
fonts.b	= "love2d/ttf/TINSSaBD.TTF"
fonts.i	= "love2d/ttf/TINSSaIT.TTF"

local nf = love.graphics.newFont

function fonts.setFont(size, style)
    if __PC.fontSupport then
        -- print("size, style", size, style)
        style	= (style and fonts[style] and style) or "r"
        size	= tonumber(size)

        local allowedSizes = {7, 9, 10, 11, 12, 16, 24} --i think 16 technically isnt allowed in lua. oh well.

        local closestSize = allowedSizes[1]
        local minDiff = math.abs(size - closestSize)

        for i = 2, #allowedSizes do
            local diff = math.abs(size - allowedSizes[i])
            if diff < minDiff then
                minDiff = diff
                closestSize = allowedSizes[i]
            end
        end

        love.graphics.setFont(nf(fonts[style], closestSize))
    end
end