--compatability: full, except some cursors not available
--tested: yes

-- https://love2d.org/wiki/love.mouse.getSystemCursor

cursor = {}

function cursor.set(name)
    if type(name) ~= "string" then
        error("cursor.set expects a string cursor name")
    end
    local cursor = __PC.cursors[name]
    if not cursor then
        print("Cursor not found:", name)
    else 
        love.mouse.setCursor(cursor)
    end
end

function cursor.hide()
    love.mouse.setVisible(false)
end

function cursor.show()
    love.mouse.setVisible(true)
end