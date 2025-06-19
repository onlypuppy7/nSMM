--compatability: unchecked
--tested: no

on = on or {}

local function callEvent(func, ...)
    if on[func] then
        return on[func](...)
    end
end

local onEvents = {
    load = function()
        callEvent("create") --todo add graphics context to this
        callEvent("construction")
    end,
    keypressed = function(key, scancode, isrepeat)
        -- Map arrow keys:
        if key == "up" then
            callEvent("arrowUp")
        elseif key == "down" then
            callEvent("arrowDown")
        elseif key == "left" then
            callEvent("arrowLeft")
        elseif key == "right" then
            callEvent("arrowRight")
        else
            -- Fallback generic arrowKey:
            if key == "up" or key == "down" or key == "left" or key == "right" then
                callEvent("arrowKey", key)
            else
                callEvent("charIn", key)
            end
        end

        -- Map special keys:
        if key == "backspace" then
            callEvent("backspaceKey")
        elseif key == "delete" then
            callEvent("deleteKey")
        elseif key == "return" then
            callEvent("enterKey")
        elseif key == "escape" then
            callEvent("escapeKey")
        elseif key == "tab" then
            callEvent("tabKey")
        elseif key == "tab" and love.keyboard.isDown("lshift", "rshift") then
            callEvent("backTabKey")
        elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            callEvent("copy")
        elseif key == "x" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            callEvent("cut")
        elseif key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            callEvent("paste")
        elseif key == "h" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and love.keyboard.isDown("lshift", "rshift") then
            callEvent("help")
        elseif key == "pause" or key == "break" then
            callEvent("help")
        end
    end,
    mousepressed = function(x, y, button)
        if button == 'l' then
            callEvent("mouseDown", x, y)
        elseif button == 'r' then
            callEvent("rightMouseDown", x, y)
            -- callEvent("grabDown", x, y)
        end
    end,
    mousereleased = function(x, y, button)
        if button == 'l' then
            callEvent("mouseUp", x, y)
        elseif button == 'r' then
            callEvent("rightMouseUp", x, y)
            -- callEvent("grabUp", x, y)
        end
    end,
    mousemoved = function(x, y, dx, dy, istouch)
        callEvent("mouseMove", x, y)
    end,
    focus = function(f)
        if not f then
            callEvent("deactivate")
            callEvent("loseFocus")
        else
            callEvent("activate")
            callEvent("getFocus")
            platform.window:invalidate()
        end
    end,
    quit = function()
        callEvent("destroy")
    end,
}

return onEvents