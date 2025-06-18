-- https://love2d.org/wiki/love.mouse.getSystemCursor

cursor = {}

-- Map documented cursor names to love2d system cursors
local cursorMap = {
    ["default"]       = "arrow",
    ["pointer"]       = "arrow",
    ["hand pointer"]  = "hand",
    ["crosshair"]     = "crosshair",
    ["hand open"]     = "hand",
    ["hand closed"]   = "hand",      -- no exact match
    ["drag grab"]     = "sizeall",   -- approximate
    ["rotation"]      = "crosshair", -- approximate
    ["translation"]   = "sizeall",   -- approximate
    ["dilation"]      = "sizenwse",  -- approximate
    ["diag resize"]   = "sizenwse",
    ["resize column"] = "sizewe",
    ["resize row"]    = "sizens",
    ["zoom in"]       = "plus",      -- no system cursor 'plus', fallback below
    ["zoom out"]      = "no",        -- approximate
    ["zoom box"]      = "crosshair", -- approximate
    ["pencil"]        = "ibeam",     -- approximate
    ["hide"]          = "no",
    ["show"]          = "arrow",
    ["clear"]         = "no",
    ["animate"]       = "arrow",
    ["interrogate"]   = "help",      -- no 'help' system cursor in love, fallback below
    ["text"]          = "ibeam",
    ["link select"]   = "hand",
    ["unavailable"]   = "no",
    ["wait busy"]     = "wait",
    ["writing"]       = "ibeam",     -- deprecated, fallback
    ["hollow pointer"]= "hand",
    ["arrow"]         = "arrow",
    ["dotted arrow"]  = "arrow",     -- no dotted arrow, fallback
    ["excel plus"]    = "plus",      -- no 'plus', fallback
    ["mod label"]     = "arrow"      -- deprecated
}

-- We don't have 'plus' or 'help' cursors in love, so fallback to 'arrow' or 'hand'
local function getSystemCursor(name)
    local c = cursorMap[name:lower()]
    if not c then return love.mouse.getSystemCursor("arrow") end

    -- 'plus' and 'help' are not valid in love, fallback:
    if c == "plus" or c == "help" then
        c = "arrow"
    end

    -- Some systems may not support all cursors; we try to create and catch errors
    local ok, sysCursor = pcall(love.mouse.getSystemCursor, c)
    if ok and sysCursor then
        return sysCursor
    else
        return love.mouse.getSystemCursor("arrow")
    end
end

local currentCursor = nil

function cursor.set(name)
    if type(name) ~= "string" then
        error("cursor.set expects a string cursor name")
    end
    currentCursor = getSystemCursor(name)
    love.mouse.setCursor(currentCursor)
end

function cursor.hide()
    love.mouse.setVisible(false)
end

function cursor.show()
    love.mouse.setVisible(true)
end