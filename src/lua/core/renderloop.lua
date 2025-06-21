function onpaint(gc)
    if framesPassed>22 then
        local runLogic=gameSpeed[1+framesPassed%(#gameSpeed)]
        if playStage.active==true then playStage:paint(gc,runLogic) end
        if editor.active==true then editor:paint(gc) end
        if titleScreen.active==true then titleScreen:paint(gc) end
        if not timerState then
            gc:drawImage(texs.safeSleep,0,92)
            if checkCollision(mouse.x,mouse.y,1,1,1,92,18,18) then gui.TEXT="Safe sleep mode active!" end
        end
        gui:paint(gc)

        if framesPassed==23 then
            recoveredLevelString=var.recall("recoveredLevel")
            if recoveredLevelString and type(recoveredLevelString)=="string" then
                print("Recovered level data found, loading...")
                gui:createPrompt("RECOVER LEVEL",{"A LEVEL WAS FOUND","FROM THE LAST SESSION.","DO YOU WANT TO LOAD IT?"},{{"YES","recoveryes"},{"NO","close"}},true,false)
                -- editor:generate(recoveredLevelString)
                -- editor.active=true
                -- titleScreen.active=false
            end
        end
        -- if framesPassed==1000 then
        --     local err=2+"e" -- this is just to test the error handling
        -- end
    else --load stuff
        gc:fillRect(0,0,screenWidth,screenHeight)
        gc:setColorRGB(173,170,173)
        drawSlantedRect(gc,{284,187,10}) drawSlantedRect(gc,{293,187,10})
        drawFont2(gc,"O", 288, 196,"left",0)
        drawFont2(gc,"P", 297, 196,"left",0)
        drawFont2(gc,"7", 306, 196,"left",0)
        gc:setColorRGB(255,255,255)
        gc:drawRect(119,192,80,10)
        gc:fillRect(121,194,77*0.1,7)
        if framesPassed==1 then
            loadFont()
        elseif framesPassed==2 then
            gc:fillRect(121,194,77*0.16,7)
            gc:drawImage(texs.R0walk3,151,170)
            drawFont(gc,"LOADING nSMM - TILES", nil, nil,"centre",0)
            entityClasses={}
            for className,object in pairs(_G) do
                if type(object)=="table" and string.sub(className,1,3)=="obj" then
                    entityClasses[className]=object
                end
            end
        elseif framesPassed==3 then
            loadTextures("tile")
            gc:fillRect(121,194,77*0.32,7)
            gc:drawImage(texs.R0walk1,151,170)
            drawFont(gc,"LOADING nSMM - GUI TEXTURES", nil, nil,"centre",0)
        elseif framesPassed==4 then
            loadTextures("gui")
            gc:fillRect(121,194,77*0.48,7)
            gc:drawImage(texs.R0walk2,151,170)
            drawFont(gc,"LOADING nSMM - OBJECT TEXTURES", nil, nil,"centre",0)
        elseif framesPassed==5 then
            loadTextures("object")
            gc:fillRect(121,194,77*0.64,7)
            gc:drawImage(texs.R0walk3,151,170)
            drawFont(gc,"LOADING nSMM - MARIO TEXTURES", nil, nil,"centre",0)
        elseif framesPassed==6 then
            loadTextures("mario1")
            gc:fillRect(121,194,77*0.8,7)
            gc:drawImage(texs.R0walk1,151,170)
            drawFont(gc,"LOADING nSMM - RECOLOUR MARIO", nil, nil,"centre",0)
        elseif framesPassed==7 then
            loadTextures("mario2")
            gc:fillRect(121,194,77,7)
        else
            drawFont(gc,"DONE!", nil, nil,"centre",0)
            gc:fillRect(121,194,77,7)
            gc:drawImage(texs.R0jump,151,170)
            if framesPassed==22 then
                gui=gui()
                playStage=playStage()
                editor=editor()
                titleScreen=titleScreen()
                titleScreen.active=true
                editor.active=false
                if notFinal then gui:createPrompt("NOT RELEASE VERSION",{"THIS VERSION IS CURRENTLY","IN DEVELOPMENT. IT MAY", "HAVE THE WRONG VERSION NUMBER","AND UNFINISHED FEATURES!!"},{{"OK","close"}},true,false) end
    end end end
    framesPassed=framesPassed+1 --global framecount
    
    local calculateFpsPer = 20

    if framesPassed % calculateFpsPer == 0 then
        local currentTime = timer.getMilliSecCounter()

        local delta = currentTime - lastTime

        fps = math.floor(10000 / delta * calculateFpsPer) / 10

        lastTime = currentTime
        if studentSoftware then
            print("FPS: " .. fps)
            Profiler:report()
        end
    end

    if framesPassed % 100 == 0 then
        collectgarbage()
        -- print("collectgarbage() called, memory usage: " .. collectgarbage("count") .. "kb")
    end
end