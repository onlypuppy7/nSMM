--compatability: unchecked
--tested: no

on = on or {}

function __PC.callEvent(func, ...)
    if on[func] then
        return on[func](...)
    end
end

--to add: timer, paint, resize(?)

__PC.onEvents = {
    load = function()
        __PC.callEvent("create") --todo add graphics context to this
        __PC.callEvent("construction")
    end,
    keypressed = function(key, scancode, isrepeat)
        -- map arrow keys:
        if key == "up" then
            __PC.callEvent("arrowUp")
        elseif key == "down" then
            __PC.callEvent("arrowDown")
        elseif key == "left" then
            __PC.callEvent("arrowLeft")
        elseif key == "right" then
            __PC.callEvent("arrowRight")
        else
            -- fallback generic arrowKey:
            if key == "up" or key == "down" or key == "left" or key == "right" then
                __PC.callEvent("arrowKey", key)
            else
                __PC.callEvent("charIn", key)
            end
        end

        -- map special keys:
        if key == "backspace" then
            __PC.callEvent("backspaceKey")
        elseif key == "delete" then
            __PC.callEvent("deleteKey")
        elseif key == "return" then
            __PC.callEvent("enterKey")
        elseif key == "escape" then
            __PC.callEvent("escapeKey")
        elseif key == "tab" then
            __PC.callEvent("tabKey")
        elseif key == "tab" and love.keyboard.isDown("lshift", "rshift") then
            __PC.callEvent("backTabKey")
        elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            __PC.callEvent("copy")
        elseif key == "x" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            __PC.callEvent("cut")
        elseif key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            __PC.callEvent("paste")
        elseif key == "h" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and love.keyboard.isDown("lshift", "rshift") then
            __PC.callEvent("help")
        elseif key == "pause" or key == "break" then
            __PC.callEvent("help")
        end
    end,
    mousepressed = function(x, y, button)
        if button == 1 then
            __PC.callEvent("mouseDown", x, y)
        elseif button == 2 then
            __PC.callEvent("rightMouseDown", x, y)
            -- __PC.callEvent("grabDown", x, y)
        end
    end,
    mousereleased = function(x, y, button)
        if button == 1 then
            __PC.callEvent("mouseUp", x, y)
        elseif button == 2 then
            __PC.callEvent("rightMouseUp", x, y)
            -- __PC.callEvent("grabUp", x, y)
        end
    end,
    mousemoved = function(x, y, dx, dy, istouch)
        __PC.callEvent("mouseMove", x, y)
    end,
    focus = function(f)
        if not f then
            __PC.callEvent("deactivate")
            __PC.callEvent("loseFocus")
        else
            __PC.callEvent("activate")
            __PC.callEvent("getFocus")
            platform.window:invalidate()
        end
    end,
    quit = function()
        __PC.callEvent("destroy")
    end,
    update = function(dt)
        -- __PC.callEvent("timer", dt)
    end,
}