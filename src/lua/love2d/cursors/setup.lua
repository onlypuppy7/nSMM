if (not __DS) and (__PC.supportsCursor or __PC.emulateCursor) then
    local cursors = {
        "default",
        "hand pointer",
        "crosshair",
        "animate",
        "clear",
        "dotted arrow",
        "pencil",
        "hand closed",
        "unavailable",
        "show",
        "pointer",
        "hand open",
        "drag grab",
        "rotation",
        "translation",
        "dilation",
        "diag resize",
        "resize column",
        "resize row",
        "zoom in",
        "zoom out",
        "zoom box",
        "hide",
        "text",
        "link select", 
        "wait busy",
        "writing",
        "hollow pointer",
        "arrow",
        "excel plus",
        "mod label"
    }

    __PC.cursors = {}
    __PC.cursorHidden = false

    for i=1, #cursors do
        local cursorName = cursors[i]

        local location = "love2d/cursors/"..cursorName:gsub(" ","_")..".png"

        print("Loading cursor:", cursorName, "from", location)

        if __PC.supportsCursor then
            local imageData = love.image.newImageData(location)
            __PC.cursors[cursorName] = love.mouse.newCursor(imageData, 16, 16)
        else
            local image = love.graphics.newImage(location)
            __PC.cursors[cursorName] = image
        end
    end

    if __PC.supportsCursor then
        cursor.set("default")
    end
end

__PC.cursorPos = {x=9999999, y=9999999}

function __PC:simulatedCursorDraw()
    if __PC.emulateCursor and __PC.cursors and (not __PC.supportsCursor) then
        if not __PC.cursorHidden then
            local img = __PC.cursorSet
            local x, y = __PC.cursorPos.x, __PC.cursorPos.y
            print(img)
            
        love.graphics.setColor(1, 1, 1)
            love.graphics.draw(img, math.floor(x), math.floor(y), 0, 1, 1, 16, 16)
        end
    end
end