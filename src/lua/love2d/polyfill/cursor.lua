--compatability: full, except some cursors not available
--tested: yes

-- https://love2d.org/wiki/love.mouse.getSystemCursor

cursor = {}

function cursor.set(name)
    if __PC.supportsCursor or __PC.emulateCursor then
        if type(name) ~= "string" then
            error("cursor.set expects a string cursor name")
        end
        __PC.cursorSet = __PC.cursors[name]
        if __PC.supportsCursor then
            if not cursor then
                print("Cursor not found:", name)
            else
                love.mouse.setCursor(__PC.cursorSet)
            end
        end
        cursor.show()
    end
end

function cursor.hide()
    if __PC.supportsCursor or __PC.emulateCursor then
        __PC.cursorHidden = true
        if __PC.supportsCursor then
            love.mouse.setVisible(false)
        end
    end
end

function cursor.show()
    if __PC.supportsCursor or __PC.emulateCursor then
        __PC.cursorHidden = false
        if __PC.supportsCursor then
            love.mouse.setVisible(true)
        end
    end
end