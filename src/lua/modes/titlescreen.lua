titleScreen=class()

function titleScreen:init()
    titleScreen.cameraOffsetX=0
    titleScreen.cameraOffsetY=8
    titleScreen:reset()
end

function titleScreen:reset()
    playStage:reset()
    gui:clear()
    --home screen       (0,0)       //  (0,0)
    gui:newButton(versText,1,290,197)
    gui:newButton("OPTIONS",true,35,197,"m-1,0")
    gui:newButton("button_create1",{"button_create2",40,30,-5,-10},111,109,"create")
    gui:newButton("button_play1",{"button_play2",40,30,-5,-10},167,109,"m1,0")
    gui:newButton("titlescreen_logo",{nil},81,37,nil)
    gui:newButton("R0idle",{nil},26,172,nil) -- i mean... its not a button. but it still works i guess!
    if debug then gui:newButton("DEBUG MODE ACTIVE!",true,159,197,"debuginfo") end
    --options screen    (-320,0)    //  (-1,0)
    gui:newButton("$",true,-298,13,"m1,0") --home icon
    gui:newButton("OPTIONS",2,-161,16)
    gui:newButton("CHANGE AUTHOR NAME",true,-161,64,"enterauthor")
    gui:newButton("CLEAR SAVED LEVELS",true,-161,84,"clearlevels")
    gui:newButton("CLEAR ALL DATA",true,-161,104,"clearall")
    gui:newButton("EXPORT DATA",true,-161,134,"exportdata")
    gui:newButton("IMPORT DATA",true,-161,154,"importdata")
    gui:newButton("R0death",{nil},-294,172,nil)
    gui:newButton("goomba1",{nil},-284,172,nil)
    --play screen       (320,0)     //  (1,0)
    gui:newButton("$",true,342,13,"m-1,0") --home icon
    gui:newButton("PLAY",3,479,16)
    gui:newButton("LOCAL LEVELS",true,479,78,"m1,0")
    gui:newButton("COURSE WORLD",true,479,98,"m0,1")
    gui:newButton("CAMPAIGN",true,479,118,"m0,-1")
    gui:newButton("ENDLESS MODE",true,479,138,"m1,-1")
    gui:newButton("R0jump",{nil},598,67,nil)
    --local screen      (640,0)     //  (2,0)
    gui:newButton("~",true,662,13,"m-1,0") --back icon
    gui:newButton("LOCAL LEVELS",2,799,16)
    gui:newButton("L2idle",{nil},928,156,nil)
    --course world      (320,-224)  //  (1,-1)
    gui:newButton("~",true,342,-211,"m0,-1")
    gui:newButton("COURSE WORLD",2,479,-208)
    gui:newButton("L0jump",{nil},603,-121,nil)
    --campaign screen   (320,224)   //  (1,1)
    gui:newButton("~",true,342,237,"m0,1") --back icon
    gui:newButton("CAMPAIGN",2,479,256)
    gui:newButton("COMING... SOON?",1,479,324)
    gui:newButton("R1crouch",{nil},346,380,nil)
    --endless screen    (640,224)   //  (2,1)
    gui:newButton("~",true,662,237,"m-1,1") --back icon
    gui:newButton("ENDLESS MODE",2,799,256)
    gui:newButton("COMING... SOON?",1,799,324)
    if username=="" then
        gui:createPrompt("WELCOME!",{"YOU DO NOT HAVE ANY","EXISTING SAVE DATA. WOULD","YOU LIKE TO IMPORT YOUR","OLD DATA OR START ANEW?"},{{"IMPORT","initimport"},{"NEW DATA","initnew"}},true,true)
    end
    titleScreen.splashText=titleSplashes[math.random(1,#titleSplashes)]
    titleScreen.framesPassedBlock=0
    titleScreen.vx=0
    titleScreen.vy=0
    local mainScreen        =string2level("<20-v6-5~5-!-500-v0.9.0a-42-my course>,1*28,*3,77,78*2,79,4*3,65,68,69,68,69,70,67,*E,65,68,69,70,67,*4,9,*B,65,68,67,*4,9,49,0,21*2,*9,66,*2,3,2,0,48,49,*12,48,49,0,74,75,76,*E,48,49,0,71,72,73,*E,48,49,*E,74,75*2,76,48,49,*E,71,72*2,73,48,49,*12,48,41,*12,40,*14")
    local optionsScreen     =string2level("<20-v6-5~3-!-500-v0.9.0a-42-my course>,1*28,86*A,85,82*7,*2,86*9,85,82*6,81,82,*2,86*8,85,82*4,81,82*4,0,9,86*7,85,82*2,81,82*3,83,82*3,0,48,86*6,85,82*B,0,48,86*5,85,82*9,81,82*2,0,48,86*4,85,82*2,81,82*3,81,82*6,0,48,86*3,85,82*6,83,82*7,0,48,86*2,85,82*9,81,82*5,0,48,86,85,82*3,81,82*3,83,82*4,81,82*3,0,48,85,3*11,0,40,*14",-20)
    local playScreen        =string2level("<20-v6-5~5-!-500-v0.9.0a-42-my course>,1*9,48,49,1*4,48,49,1*2,0,1*9,40,41,1*4,48,49,1*2,*6,77,78,79,*3,87*2,0,9,48,49,9*2,*10,48,49,9*2,0,9,*E,40,41,9*2,0,49,*2,2*2,*C,9*2,0,49,*13,49,*11,4,0,49,*12,4,49,*D,74,75*2,76,*2,49,*D,71,72*2,73,*2,49,*13,41,*27",20)
    local localScreen       =string2level("<20-v6-5~5-!-500-v0.9.0a-42-my course>,0,1*13,0,1*13,0,9*4,69,70,67,77,78*2,79,*4,82*2,86,82,0,9*3,65,68,67,*9,82*2,85,82,0,9*2,*2,66,*A,80,84*3,*11,81,82,83,*11,80*3,0,4,*12,4,*38,74,75*2,*11,71,72*2,*28",40)
    local courseWorldScreen =string2level("<20-v5-5~5-!-500>,*15,11*12,*2,87*12,*81,74,75*3,76,*8,74,75*2,76,*3,71,72*3,73,*2,74,75,76,*3,71,72*2,73,*A,71,72,73,*17,*15",20,14)
    local campaignScreen    =string2level("<20-v5-5~5-!-500>,1*14,9,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*D,46,50*5,9,*8,43,42,*3,47,52,53,51*3,9*9,48,49,9*4,48,49,9*3,1*14",20,-13)
    local endlessScreen     =string2level("<20-v5-5~5-!-500>,1*14,9,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9*2,*12,9,50,45,*11,9,51,44,*11,9*15,1*14",40,-13)
    
    level.current=mainScreen
    level.current.xy=table.merge(
        mainScreen.xy,
        localScreen.xy,
        courseWorldScreen.xy,
        campaignScreen.xy,
        endlessScreen.xy,
        optionsScreen.xy,
        playScreen.xy
    )
    
    for i=-21,21 do level.current.set(i,14,9) end
    for i=21,60 do level.current.set(i,-13,1) end
end

function titleScreen:charIn(chr)
    if chr=="d" then
        debug=not debug
        titleScreen:init()
    end
end

function titleScreen:drawTerrain(gc) --rendered in rows from bottom to top w/ the rows from left to right. this script supports y level scrolling
    local objectList={}
    for i2=math.ceil(titleScreen.cameraOffsetX/16),math.ceil((screenWidth+titleScreen.cameraOffsetX)/16) do --left to right, horizontally, only draw what is visible on screen
        local THEME=1
        for i=math.ceil(titleScreen.cameraOffsetY/16),math.ceil((screenHeight+titleScreen.cameraOffsetY)/16) do --bottom to top, vertically
            local blockID=plot2ID(i2,i)
            if type(blockID)=='number' then --its a tile. this particular hacked together drawTerrain script cannot do anything else besides it.
                if blockID<0 then blockID=0 end
                if i<1 and blockIndex[blockID]["theme"][THEME]~=nil then
                    local frameForAnim=(math.floor((titleScreen.framesPassedBlock/4)%#blockIndex[blockID]["theme"][THEME]))+1 --(support for animations)
                    gc:drawImage(texs[blockIndex[blockID]["theme"][THEME][frameForAnim]], ((i2-1)*16)-titleScreen.cameraOffsetX, 212-16*(i)+titleScreen.cameraOffsetY)
                elseif blockIndex[blockID]["texture"][1]~=nil then
                    local frameForAnim=(math.floor((titleScreen.framesPassedBlock/4)%#blockIndex[blockID]["texture"]))+1 --(support for animations)
                    gc:drawImage(texs[blockIndex[blockID]["texture"][frameForAnim]], ((i2-1)*16)-titleScreen.cameraOffsetX, 212-16*(i)+titleScreen.cameraOffsetY) end
end end end end

function titleScreen:drawBackground(gc)
    gc:setColorRGB(97,133,248)
    gc:fillRect(0,0,screenWidth,212)
    gc:setColorRGB(0,0,0)
    gc:fillRect(0,212+titleScreen.cameraOffsetY,screenWidth,216) --below ground. anything below y pixel 212 will be the underground theme
end

function titleScreen:moveScreens(x,y)
    x=x or 0 y=y or 0
    titleScreen.vx=(x*16)+titleScreen.vx
    titleScreen.vy=(y*16)+titleScreen.vy
end

function titleScreen:mouseDown()
end

function titleScreen:escapeKey()
    if titleScreen.vx==0 and titleScreen.vy==0 then
        gui:detectPos(titleScreen.cameraOffsetX,titleScreen.cameraOffsetY,23,17) --select the top left button...
        gui:click() --and click it. could be handled differently, but it works.
    end
end

function titleScreen:paint(gc)
    cursor.show()
    titleScreen.framesPassedBlock=titleScreen.framesPassedBlock+1
    if (titleScreen.vx~=0 or titleScreen.vy~=0) and not gui.PROMPT then
        switchTimer(true)
        if math.abs(titleScreen.vx)>0 then
            titleScreen.cameraOffsetX=titleScreen.cameraOffsetX+((titleScreen.vx/math.abs(titleScreen.vx))*20)
            titleScreen.vx=titleScreen.vx-(titleScreen.vx/math.abs(titleScreen.vx))
        end
        if math.abs(titleScreen.vy)>0 then
            titleScreen.cameraOffsetY=titleScreen.cameraOffsetY+((titleScreen.vy/math.abs(titleScreen.vy))*14)
            titleScreen.vy=titleScreen.vy-(titleScreen.vy/math.abs(titleScreen.vy))
        end
    else
        switchTimer(false)
        gui:detectPos(titleScreen.cameraOffsetX,titleScreen.cameraOffsetY)
    end
    titleScreen:drawBackground(gc)
    titleScreen:drawTerrain(gc)
    if username~="" then
        drawFont(gc,"WELCOME BACK "..username.."!",159-titleScreen.cameraOffsetX,6+titleScreen.cameraOffsetY,"centre",false,true)
        drawFont(gc,titleScreen.splashText,159-titleScreen.cameraOffsetX,17+titleScreen.cameraOffsetY,"centre",nil,"rgb")
    end
    __PC.allowedHeldKeys = {}
end