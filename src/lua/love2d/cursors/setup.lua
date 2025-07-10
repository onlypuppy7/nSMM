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

if not __DS then
    for i=1, #cursors do
        local cursorName = cursors[i]

        local location = "love2d/cursors/"..cursorName:gsub(" ","_")..".png"

        print("Loading cursor:", cursorName, "from", location)

        local imageData = love.image.newImageData(location)
        __PC.cursors[cursorName] = love.mouse.newCursor(imageData, 16, 16)

        love.mouse.setCursor(__PC.cursors[cursorName])
    end
end