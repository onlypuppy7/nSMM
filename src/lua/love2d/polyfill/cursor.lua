--compatability: full, except some cursors not available
--tested: yes

-- https://love2d.org/wiki/love.mouse.getSystemCursor

cursor = {}

function cursor.set(name)
    if love.mouse then
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
end

function cursor.hide()
    if love.mouse then
        love.mouse.setVisible(false)
    end
end

function cursor.show()
    if love.mouse then
        love.mouse.setVisible(true)
    end
end