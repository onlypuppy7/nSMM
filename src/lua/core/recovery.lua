function drawCrashScreen(gc,err)
    gc:setColorRGB(0,0,0)
    gc:fillRect(0,0,screenWidth,screenHeight)
    gc:setColorRGB(97,133,248) --daytime
    gc:fillRect(0,0,screenWidth,75)
    gc:setColorRGB(255,0,0)
    gc:drawRect(0,0,screenWidth-1,screenHeight-1)
    gc:setColorRGB(255,255,255)

    if texs.titlescreen_logo then
        gc:drawImage(texs.titlescreen_logo,81,12)
    end

    local offset=55

    drawFont(gc,"nSMM - CRASH SCREEN", nil, 30+offset,"centre",0,true)
    drawFont(gc,"An error has occurred in the program.", nil, 40+offset,"centre",0,true)
    local errSplit=tostring(err):split("...")
    drawFont(gc,"Error message:", nil, 60+offset,"centre",0,true)
    drawFont(gc,errSplit[1].."...", nil, 70+offset,"centre",0,true)
    local errSplit2=errSplit[2]:split(" ")
    --join together the first half and the second half of the error message
    local errPart1, errPart2 = "", ""
    for i=1,math.floor(#errSplit2/2) do
        errPart1 = errPart1 .. errSplit2[i] .. " "
    end
    for i=math.floor(#errSplit2/2)+1,#errSplit2 do
        errPart2 = errPart2 .. errSplit2[i] .. " "
    end
    --draw the two parts of the error message
    drawFont(gc,errPart1, nil, 80+offset,"centre",0,true)
    drawFont(gc,errPart2, nil, 90+offset,"centre",0,true)

    drawFont(gc,"Press any key, then:", nil, 110+offset,"centre",0,true)
    drawFont(gc,"Menu -) Recover -) Restart Script", nil, 120+offset,"centre",0,true)

    if texs.R0death then
        gc:drawImage(texs.R0death,screenWidth/2-16,132+offset)
    end
end

function onexit()
    local inStage=playStage.active and playStage.EDITOR
    local inEditor=editor.active

    if inStage or inEditor then
        local levelString
        if inStage then
            levelString=level.perm
        elseif inEditor then
            levelString=level2string(level.current)
        end
        print("Saving level data before exit...", levelString)
        var.store("recoveredLevel", levelString)
        print("Level data saved successfully.")
    end
end