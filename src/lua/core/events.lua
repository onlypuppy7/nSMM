function on.enterKey()
    if not gui.PROMPT then
        if editor.active==true and not editor.levelList then editor.enterKey()
        elseif playStage.active==true then playStage.enterKey() end
    else gui:enterKey()
    end
end

function on.charIn(chr)
    if errored then error(errored) end
    if gui.PROMPT then
        gui:charIn(tostring(chr))
    elseif playStage.active==true then
        playStage:charIn(chr)
    elseif editor.active==true and not editor.levelList then
        editor:charIn(chr)
    elseif titleScreen.active==true then
        titleScreen:charIn(chr)
    end
end

function on.timer()
    if not frameByFrame then platform.window:invalidate() end --refreshes screen
    if editor.LOAD==2 then editor:updateToolpalette() editor.LOAD=3 end
    if editor.active and (playStage.active or titleScreen.active) then
        toolpalette.register({
            {"Game Speed",
                {"0.25x", toolpaletteSelection},
                {"0.5x", toolpaletteSelection},
                {"0.75x", toolpaletteSelection},
                {"1x", toolpaletteSelection},
                {"1.25x", toolpaletteSelection},
                {"1.5x", toolpaletteSelection},
                {"1.75x", toolpaletteSelection},
                {"2x", toolpaletteSelection}
            }
        })
        editor.active=false
    end
end

function on.resize() 
    screenWidth=platform.window:width() 
    screenHeight=platform.window:height() 
end

function on.escapeKey()
    if not gui.PROMPT then
        if playStage.active==true then playStage:escapeKey()
        elseif editor.active==true then editor:escapeKey()
        elseif titleScreen.active==true then titleScreen:escapeKey() end
    else gui:escapeKey()
end end

function on.copy()
end

function on.paste()
end

function on.arrowRight()
    if not gui.PROMPT then
        if playStage.active==true then playStage.arrowRight()
        elseif editor.active==true then editor.arrowRight()
end end end

function on.arrowLeft()
    if not gui.PROMPT then
        if playStage.active==true then playStage.arrowLeft()
        elseif editor.active==true then editor.arrowLeft()
end end end

function on.arrowUp()
    if not gui.PROMPT then
        if playStage.active==true then playStage.arrowUp()
        elseif editor.active==true and not editor.levelList then editor:arrowUp()
        elseif titleScreen.active==true or editor.levelList then gui:scroll("U")
end end end

function on.arrowDown()
    if not gui.PROMPT then
        if playStage.active==true then playStage.arrowDown()
        elseif editor.active==true and not editor.levelList then editor:arrowDown()
        elseif titleScreen.active==true or editor.levelList then gui:scroll("D")
end end end

function on.backspaceKey()
    if gui.PROMPT or editor.levelList then gui:backspaceKey()
    elseif editor.active==true then editor:backspaceKey()
end end

function on.mouseDown(x,y)
    if not gui.PROMPT then
        if playStage.active==true then playStage:mouseDown()
        elseif editor.active==true then editor:mouseDown()
        elseif titleScreen.active==true then titleScreen:mouseDown()
    end end
    gui:click()
end

function on.rightMouseDown(x,y)
    if not gui.PROMPT then
        if playStage.active==true then playStage:rightMouseDown()
        elseif editor.active==true then editor:rightMouseDown()
end end end

function on.grabDown(x,y) on.rightMouseDown() end

function on.mouseMove(x,y) mouse.x,mouse.y=x,y end

function on.destroy()
    onexit()
end

function on.deactivate()
    onexit()
end

function on.loseFocus()
    onexit()
end

function on.save()
    onexit()
end

function on.paint(gc)
    --pcall the onpaint function, which is the main paint function
    local function func(trycatch)
        local success, err = true, nil
        if not studentSoftware then Profiler:start("onpaint", false, "onpaint") end
        if trycatch then
            success, err = pcall(onpaint, gc)
            if not success then
                print("Error in onpaint: " .. tostring(err))
                errored = err
                onexit()
            end
        else
            onpaint(gc)
        end
        if not studentSoftware then Profiler:stop("onpaint") end
        return success, err
    end

    if not errored then
        func(not debug)
    else
        drawCrashScreen(gc, errored)
    end
end