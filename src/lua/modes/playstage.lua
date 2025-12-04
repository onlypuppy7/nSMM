playStage=class()
--math.ceil(playStage.cameraOffset/16),math.ceil((320+playStage.cameraOffset)/16)

function playStage:generate(LEVELSTRING,transition,EDITOR)
    gui:clear() --editor.active=false
    cursor.set("default")
    level.perm=LEVELSTRING
    playStage.EDITOR=EDITOR
    if transition==true then
        playStage.transition=20
    end
    self:reset()
end

function playStage:reset()
    playStage:clearEntities()
    mario.trail={}
    playStage.SCORE=0
    playStage.coinCount=0
    playStage.framesPassed=0
    mario.framesPassed=0
    playStage.framesPassedBlock=0
    playStage.cameraBias=30
    playStage.load=0
    playStage.transition=0 playStage.transition2=false
    input.left=0 input.right=0 input.up=0 input.down=0 input.action=0 input.stor.left=0 input.stor.right=0 input.stor.up=0 input.stor.down=0 input.stor.action=0
    playStage.events={
        onoff=true,
        pswitch=false,
    }
    playStage.playedHurry=false
    playStage.currentBGM=false
end

function playStage:init()
    entityLists={
        background={},
        inner={},
        outer={},
        particle={},
    }
    allEntities={}
    level.current=destroyObject(level.current,{})
    playStage.active=false
    playStage.wait=false
    playStage.events={}
    mario:init()
end

function playStage:clearEntities()
    for k in pairs(entityLists) do
        entityLists[k] = {}
    end
    allEntities={}
    cleanupListDestroy={}
    cleanupListTransfer={}
    hitBoxList={}
    playStage.platformList={}
    playStage.platformListAdd={}
end

--BUTTON INPUTS
    function playStage:charIn(chr)
        if chr=="−" or chr==" " then playStage:handleInput("action")
        elseif chr=="2" then         playStage:handleInput("down")
        elseif chr=="4" then         playStage:handleInput("left")
        elseif chr=="6" then         playStage:handleInput("right")
        elseif chr=="5" then         playStage:handleInput("up")
        elseif chr=="restart" then   playStage:generate(level.perm)
        elseif chr=="edit" and level.current.get(1,1)~=nil then
            local fileSTOR=editor.file
            editor:generate(level.perm)
            editor.active=true editor.file=fileSTOR playStage.active=false
            editor.cameraOffset=math.floor(playStage.cameraOffset/20)*20
        end
        if _DEBUG_ then --these are mostly legacy functions, prevailing from the most early versions of nsmm
            if chr=="1" then
                mario:powerUpMario()
            elseif chr=="2" then
                mario.y=mario.y-3
                mario.x=mario.x+2
            elseif chr=="8" then
                mario.x=mario.x-1
            elseif chr=="9" then
                mario.x=mario.x+1
            elseif chr=="0" then
                mario:powerDownMario()
            elseif chr=="r" and level.current.get(1,1)~=nil then playStage:randomise()
            elseif chr=="f" then frameByFrame=not frameByFrame
            elseif chr=="y" then mario.x=73*16
            elseif chr=="d" then
                _DEBUG_=not _DEBUG_
            elseif chr=="g" then
                mario:clearedLevel(190)
            elseif chr=="v" then
                on.mouseDown()
            elseif chr=="c" then
                print(level.perm)
            elseif chr=="s" then
                clipboard.addText(level.perm)
            elseif chr=="l" then
                local PASTE=clipboard.getText()
                if string.sub(PASTE,1,1)=="<" then --very crude for now
                    playStage:generate(PASTE)
                    mario:resetPos()
                end
            elseif chr=="j" then
                blockSelectionTEMP=blockSelectionTEMP-1
            elseif chr=="k" then
                blockSelectionTEMP=blockSelectionTEMP+1
            elseif chr=="p" then
                playStage:PAUSE()
            end
        end
    end
    function playStage:escapeKey()
        playStage:PAUSE()
    end
    function playStage:arrowUp()
        playStage:handleInput("up")
    end
    function playStage:arrowDown()
        playStage:handleInput("down")
    end
    function playStage:arrowLeft()
        playStage:handleInput("left")
    end
    function playStage:arrowRight()
        playStage:handleInput("right")
    end
    function playStage:enterKey()
        if playStage.EDITOR then playStage:charIn("edit") end
    end
    function playStage:mouseDown()
        if _DEBUG_ then
            local placeXY=pixel2plot(mouse.x,mouse.y-8)
            level.current.set(placeXY[1], placeXY[2], blockSelectionListTEMP[(blockSelectionTEMP%(#blockSelectionListTEMP))+1])
        end
        if playStage.EDITOR and checkCollision(mouse.x,mouse.y,1,1,4,178,40,30) then
            playStage:charIn("edit")
        end
    end
    function playStage:rightMouseDown()
        if _DEBUG_ then
            local placeXY=pixel2plot(mouse.x,mouse.y-8)
            level.current.set(placeXY[1], placeXY[2], 0)
        end
    end

function playStage:PAUSE() --true/false
    gui:clear()
    if playStage.EDITOR or mario.dead then gui:createPrompt("PAUSED",nil,{{"RESUME","unpause"},{"EDIT","play_edit"},{"QUIT","quit"}},false)
    else                                   gui:createPrompt("PAUSED",nil,{{"RESUME","unpause"},{"RETRY","play_retry"},{"EDIT","play_edit"},{"QUIT","quit"}},false)
    end
    __PC.SOUND:sfx("pause")
end

function playStage:handleInput(INPUT)
    if INPUT~=nil and not mario.clear then
        input[INPUT]=1
        if     INPUT=="down" and not mario.clear then   input.stor.down=8
        elseif INPUT=="up" and not mario.clear then     input.stor.up=2
        elseif INPUT=="action" and not mario.clear then input.stor.action=2
        elseif not level.current.autoMove then           input.stor[INPUT]=6
        end
    else
        input.stor.up=input.stor.up-1
        input.stor.down=input.stor.down-1
        input.stor.left=input.stor.left-1
        input.stor.right=input.stor.right-1
        input.stor.action=input.stor.action-1
        
        if level.current.autoMove then input.left=0 input.right=1
        else
            if input.stor.left>0 then input.left=1 else input.left=0 end
            if input.stor.right>0 then input.right=1 else input.right=0 end
        end

        if input.stor.up>0 then input.up=1 else input.up=0 end
        if input.stor.down>0 then input.down=1 else input.down=0 end
        if input.stor.action>0 then input.action=1 else input.action=0 end
    end
end

function playStage:completeStage(condition) --"dead" or "goal"
    if not playStage.EDITOR then
        if condition=="dead" then playStage:charIn("restart")
        elseif condition=="goal" then gui:click("quitconfirm")
        end
    else
        playStage:charIn("edit")
    end
end

function playStage:randomise() --entertaining but ultimately useless (... FOR NOW!!)

    -- math.randomseed(1)

    local level=string2level(defaultCourse) --a relic of the past i think
    
    local levelWidth,levelHeight=200,13 --width/height
    local groundHeight=3 --ground parameters
    local minHeight,maxHeight=groundHeight-2,groundHeight+2
    local flatnessThreshold=1-(0.8) --how flat the ground should be (0 = completely flat, 1 = completely random)
    local pitFrequency=0.05 --frequency of pits of death (0 = none, 1 = very frequent)
    local enemyTable={{"goomba",0.02},{"koopa_R",0.02},{"koopa_G",0.02},{"bullet_L",0.03,2}} -- table of possible enemies and their probabilities
    local blockFrequency=0.05
    local blockTable={{22,0.05},{2,0.07},{23,0.03},{24,0.02},{36,0.04},{33,0.05}} -- table of possible blocks and their probabilities

    local function generateGround()
        local lastHeight,x,lastRow=groundHeight,1,0
        while x<=levelWidth do
    --GROUND GENERATION
            local height=lastHeight
            if math.random()>flatnessThreshold then
                height=lastHeight+math.random(-1,1)
                if height<minHeight then
                height=minHeight
                elseif height>maxHeight then
                height=maxHeight
            end end
            for y=1,levelHeight do
                if y<=height then level.set(x,y,1)
                elseif level.get(x,y)==nil then level.set(x,y,0)
            end end lastHeight=height
    --PIT SPAWNING
            if math.random()<pitFrequency and x>6 then x=x+math.random(2,4)
            end
    --BLOCK SPAWNING
            if lastRow<=0 and blockFrequency>math.random() then
                local blockY=0
                for y=1,levelHeight do
                    if level.get(x,y)==0 then
                        blockY=y break
                end end
                local rowLength=math.random(1,4)
                for x2=x,x+rowLength do
                    local blockProb,chosenBlock=math.random(),3
                    for _, block in ipairs(blockTable) do
                        if blockProb<=block[2] then chosenBlock=block[1] break
                        else blockProb=blockProb-block[2]
                        end end
                    level.set(x2,blockY+4,chosenBlock)
                end
                lastRow=rowLength+4
            end lastRow=lastRow-1
    --ENEMY SPAWNING
            if x>6 then
                local enemyProb=math.random()
                for _, enemy in ipairs(enemyTable) do
                    if enemyProb<=enemy[2] then
                        local enemyX,enemyY=x,0
                        for y=1,levelHeight do
                            if level.get(x,y)==0 then
                                enemyY=y break
                        end end level.set(enemyX,(enemyY+math.random(0,enemy[3] or 0)),enemy[1]) break
                    else enemyProb=enemyProb-enemy[2]
            end end end
            x=x+1
        end
    end

    generateGround()
    
    local starts=plot2pixel(3,5)
    level.startX=starts[1] level.startY=starts[2] 
    level.set(2,5,0) level.TIME=500 level.END=levelWidth
    playStage:generate(level2string(level))
end

function playStage:drawTerrain(gc) --rendered in rows from bottom to top w/ the rows from left to right
    for i2=math.ceil(playStage.cameraOffset/16),math.ceil((screenWidth+playStage.cameraOffset)/16) do --left to right, horizontally, only draw what is visible on screen
        local THEME=plot2theme(i2)
        for i=1,13 do --bottom to top, vertically (row 14 is reserved for hud/special events and is not drawn)
            local blockID=plot2ID(i2,i)
            if type(blockID)=="number" then --themed blocks
                drawTile(gc, blockID, i2, i, "playStage", THEME)
                -- if blockID<0 then blockID=0 end
                -- if blockIndex[blockID]["theme"][THEME]~=nil then
                --     local animSpeed=blockIndex[blockID]["animSpeed"] or 4 --default animation speed
                --     local frameForAnim=(math.floor((playStage.framesPassedBlock/animSpeed)%#blockIndex[blockID]["theme"][THEME]))+1 --(support for animations)
                --     gc:drawImage(texs[blockIndex[blockID]["theme"][THEME][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i)+8)
                --     if i==13 and blockIndex[blockID]["ceiling"] and level.current.showCeilingBlock then gc:drawImage(texs[blockIndex[blockID]["theme"][THEME][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i+1)+8) end --draw a block above the blocks to denote that mario cannot jump over it
                -- elseif blockIndex[blockID]["texture"][1]~=nil then --it has an animation
                --     local animSpeed=blockIndex[blockID]["animSpeed"] or 4 --default animation speed
                --     local frameForAnim=(math.floor((playStage.framesPassedBlock/animSpeed)%#blockIndex[blockID]["texture"]))+1 --(support for animations)
                --     gc:drawImage(texs[blockIndex[blockID]["texture"][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i)+8)
                --     if i==13 and blockIndex[blockID]["ceiling"] and level.current.showCeilingBlock then gc:drawImage(texs[blockIndex[blockID]["texture"][frameForAnim]], ((i2-1)*16)-playStage.cameraOffset, 212-16*(i+1)+8) end --draw a block above the blocks to denote that mario cannot jump over it
                -- end --^^^ CAUTION so far no animated blocks are ceiling ones.. if they are then this will cease to work!
            else --load the object
                table.insert(level.current.loadedObjects,{blockID,i2,i}) --to load back if there's a pipe transition
                plot2place(0,i2,i) --blank it out
                objAPI:createObj(blockID,(i2-1)*16,212-16*(i),false)
            end
        end
    end
end

function playStage:drawBackground(gc) --rendered in rows from bottom to top w/ the rows from left to right
    for i=math.ceil(playStage.cameraOffset/16),math.ceil((screenWidth+playStage.cameraOffset)/16) do --left to right, horizontally, only draw what is visible on screen
        local THEME=plot2theme(i)
        if THEME==0 then gc:setColorRGB(97,133,248) --daytime
        else gc:setColorRGB(0,0,0) --underground or nighttime or castle
        end
        -- print(screenWidth, screenHeight)
        gc:fillRect(((i-1)*16)-playStage.cameraOffset,0,18,math.min(220, screenHeight)) --backdrop
end end

function playStage:levelLogic()
    if checkCollision(mouse.x,mouse.y,1,1,4,178,40,30) and playStage.EDITOR then
        cursor.set("hand pointer") --simple bounding of clapperboard in corner
    else cursor.set("default")
    end
    playStage.framesPassedBlock=playStage.framesPassedBlock+1
    if not mario.dead and not mario.clear then
        playStage.TIME=level.current.TIME-(math.floor(playStage.framesPassed/18))
        if playStage.TIME<=0 then mario:kill() end
    end
    playStage:playBGM()
end

function playStage:scrollCamera(force)
    if (not (mario.clear or mario.dead)) then
        playStage.cameraTargetOffset=playStage.cameraOffset
        if level.current.autoScroll then
            if playStage.cameraOffset>=playStage.levelWidth-318 then
                playStage.cameraTargetOffset=playStage.levelWidth-318
            elseif not (playStage.wait or gui.PROMPT) and playStage.cameraOffset~=playStage.levelWidth-318 then
                playStage.cameraTargetOffset=playStage.cameraOffset+level.current.autoScroll
            end
        elseif (playStage.wait==false) and (not mario.powerUp) then
            local biasBoundary=48 --distance from centre (159) that mario has to travel to change the bias direction
            if mario.x>159 then --if progressed past initial screen centre
                if not (level.current.disableBackScrolling==true and ((mario.x+8-159+math.abs(playStage.cameraBias))<playStage.cameraOffset)) then
                    if (mario.x-playStage.cameraOffset+8)>159+biasBoundary and (mario.vx>=1 or mario.vx==0) then --passed right side boundary
                        playStage.cameraBias=math.abs(playStage.cameraBias)
                    elseif (mario.x-playStage.cameraOffset+8)<159-biasBoundary and (mario.vx<=-1 or mario.vx==0) then --passed left side boundary
                        playStage.cameraBias=-math.abs(playStage.cameraBias)
                    end
                    if playStage.cameraBias==math.abs(playStage.cameraBias) and (mario.x-playStage.cameraOffset+8)<159-playStage.cameraBias then
                    elseif playStage.cameraBias==-math.abs(playStage.cameraBias) and (mario.x-playStage.cameraOffset+8)>159-playStage.cameraBias then
                    else
                        playStage.cameraTargetOffset=mario.x+8-159+playStage.cameraBias
                    end
                end
            elseif level.current.disableBackScrolling~=true then
                playStage.cameraTargetOffset=0
            end
        end
    end
    --scroll stop
    local function posInList(list,num,bodge) --find position in list greater than num
        if list[1]>=num and bodge then return 2 end --wtf is this
        for i=1,#list do
            if list[i]>=num then return i end
        end return #list+(bodge or 0) --i'm really sorry for this
    end
    -- local posLeft,posRight=0,playStage.levelWidth-318 --never scroll past these
    local posLeft=level.current.scrollStopL[math.max(math.min(posInList(level.current.scrollStopL,mario.x+3,1),posInList(level.current.scrollStopL,playStage.cameraOffset,1)),posInList(level.current.scrollStopL,playStage.cameraTargetOffset,1))-1]
    local posRight=level.current.scrollStopR[math.max(math.min(posInList(level.current.scrollStopR,playStage.cameraTargetOffset),posInList(level.current.scrollStopR,playStage.cameraOffset)),posInList(level.current.scrollStopR,mario.x-306))] --this is held together with post it note glue
    playStage.cameraTargetOffset=math.max(posLeft,math.min(playStage.cameraTargetOffset,posRight)) --clamp values to scroll stops --CONSIDER THIS FOR SCROLL STOP
    --smooth scrolling
    local lerpFactor=level.current.autoScroll and 0.5 or (mario.clear or mario.dead) and 0.25 or force or 0.15 --the lerpFactor (scrolling smoothness (higher=smoother))
    playStage.cameraOffset=math.round(playStage.cameraOffset+(playStage.cameraTargetOffset-playStage.cameraOffset)*lerpFactor,4)
    playStage.cameraOffset=math.max(0,math.min(playStage.cameraOffset,playStage.levelWidth-318)) --clamp values to level borders --CONSIDER THIS FOR SCROLL STOP
    -- print(playStage.cameraOffset, playStage.cameraTargetOffset, posLeft, posRight)
    if level.current.autoMove and playStage.cameraOffset>=playStage.levelWidth-318 then
        level.current.autoMove=nil
    end
end

function playStage:getSpawnOffsets()
    --view distance plus 3 blocks
    local spawnOffsetX=math.ceil(playStage.cameraOffset/16)*16-48 --left side
    local spawnOffsetY=math.ceil((screenWidth+playStage.cameraOffset)/16)*16+48 --right side
    return spawnOffsetX,spawnOffsetY
end

function playStage:objLogic()
    if not playStage.wait and not mario.powerUp then
        local spawnOffsetX,spawnOffsetY=playStage:getSpawnOffsets() --get the view distance
        for k in pairs(entityLists) do
            local focusedList=entityLists[k]
            for i=1,#focusedList do --for all entities within the list
                local entity=allEntities[focusedList[i]]
                if entity~=nil and entity.objectID then --if entity exists
                    if ((entity.y)>212) then
                        -- print("offscreen y",entity.TYPE)
                        objAPI:destroyObject(entity.objectID,entity.LEVEL)
                    elseif (((entity.x) > (spawnOffsetX)) and ((entity.x) < (spawnOffsetY))) or (entity.GLOBAL==true) or level.current.enableGlobalEntities==true then --if in view distance
                        entity:performLogic()
                        -- print("logic",entity.TYPE)
                    elseif entity.despawnable then
                        -- print("despawn1",entity.TYPE)
                        if entity.x<-16 or (entity.x < spawnOffsetX+8) or ((entity.x) > spawnOffsetY-8) then
                            -- print("despawn2",entity.TYPE)
                            objAPI:destroyObject(entity.objectID,entity.LEVEL) end
                    end
                else table.remove(focusedList,i) end --get rid of blank entities that may occur as a result of overloading, NOT a substantial issue
end end end end

function playStage:objDraw(gc,entityLists)
    local spawnOffsetX,spawnOffsetY=playStage:getSpawnOffsets() --get the view distance
    for k in pairs(entityLists) do
        local focusedList=entityLists[k]
        for i=1,#focusedList do
            local entity=allEntities[focusedList[i]]
            -- print(entity)
            if entity~=nil and entity.objectID then
                if (not ((entity.x) < (spawnOffsetX)) and not ((entity.x) > (spawnOffsetY))) or entity.GLOBAL==true then
                    local obj=allEntities[focusedList[i]]
                    obj:draw(gc,obj.x-playStage.cameraOffset,obj.y+8,obj.TYPE,false,false) --:draw(gc,x,y,TYPE,isEditor,isIcon)
end end end end end

function playStage:paint(gc,runLogic) --all logic/drawing required to play the stage
    if playStage.load>1 then
    --logic
        Profiler:start("playStage:paint logic", false, "playStage:paint logic")
        for i=1,runLogic do
            if playStage.transition<=10 and not gui.PROMPT then
                if not playStage.wait then
                    playStage.framesPassed=playStage.framesPassed+1
                    objAPI:updatePlatforms()
                end
                if (not playStage.wait) or mario.pipe then
                    mario.framesPassed=mario.framesPassed+1
                end
                Profiler:start("playStage:levelLogic", true, "playStage:paint logic")
                playStage:levelLogic() --timer etc
                Profiler:start("playStage:scrollCamera", true, "playStage:paint logic")
                playStage:scrollCamera() --scrolling
                Profiler:start("playStage:handleInput", true, "playStage:paint logic")
                playStage:handleInput() --receive information from keys pressed and parse it
                Profiler:start("playStage:objLogic", true, "playStage:paint logic")
                playStage:objLogic() --logic for every obj (powerups, enemies etc) except mario
                -- if playStage.framesPassed%2==0 then --every other frame
                    Profiler:start("objAPI:cleanup", true, "playStage:paint logic")
                    objAPI:cleanup() --transfers layers, destroys queued objects
                -- end
                Profiler:start("mario:logic", true, "playStage:paint logic")
                mario:logic()
            end
        end
        Profiler:stop("playStage:paint logic")
        
    --drawing (terrain and most objs)
        Profiler:start("playStage:paint drawing", false, "playStage:paint drawing")

        Profiler:start("playStage:drawBackground", true, "playStage:paint drawing")
        playStage:drawBackground(gc)
        Profiler:start("playStage:objDraw background", true, "playStage:paint drawing")
        playStage:objDraw(gc,{entityLists.background})
        if mario.pipe then
            Profiler:start("mario:draw", true, "playStage:paint drawing")
            mario:draw(gc)
        end
        Profiler:start("playStage:drawTerrain", true, "playStage:paint drawing")
        playStage:drawTerrain(gc)
        Profiler:start("playStage:objDraw inner outer", true, "playStage:paint drawing")
        playStage:objDraw(gc,{entityLists.inner,entityLists.outer})
        if not mario.pipe then
            Profiler:start("mario:draw", true, "playStage:paint drawing")
            mario:draw(gc)
        end
        Profiler:start("playStage:objDraw particle", true, "playStage:paint drawing")
        playStage:objDraw(gc,{entityLists.particle})
        if playStage.transition2 then
            Profiler:start("playStage:drawCircleTransition", true, "playStage:paint drawing")
            playStage:drawCircleTransition(gc,unpack(playStage.transition2))
        end
    
    --hud (coins= %^&)
        Profiler:start("playStage:paint HUD", true, "playStage:paint drawing")
        local frameForAnim=(math.floor((framesPassed/4)%6))+1
        if frameForAnim<4 then frameForAnim="[" elseif frameForAnim==5 then frameForAnim="}" else frameForAnim="{" end
        local hud1=frameForAnim.."+"..addZeros(playStage.coinCount,2)
        local hud2=addZeros(playStage.SCORE,6).." > "..addZeros(playStage.TIME,3)
        if false then hud1="< +".."lives".." " end
        drawFont(gc,hud1,2,2,"left")
        drawFont(gc,hud2,316,2,"right")
        if playStage.TIME<=0 and not mario.clear then drawFont(gc,"TIME UP",nil,nil,"centre") end
        if playStage.EDITOR then
            if checkCollision(mouse.x,mouse.y,1,1,4,178,40,30) then gc:drawImage(texs.button_create2,1,168)
            else gc:drawImage(texs.button_create1,6,178)
            end gc:drawImage(texs.prompt_enter,28,203)
        end
        if playStage.events.pswitch then
            -- draw a countdown bar
            local switchStart=playStage.events.pswitch[1]
            local switchEnd=playStage.events.pswitch[2]
            local switchLength=switchEnd-switchStart
            local switchTime=playStage.framesPassed-switchStart
            local switchPercent=switchTime/switchLength

            if switchPercent>=1 then
                playStage.events.pswitch=nil --omg logic in the paint function
            else
                local barWidth=100
                local barHeight=4
                local barY=48
                local barX=screenWidth/2-barWidth/2
                local fillWidth=barWidth - math.floor(barWidth * switchPercent)

                if switchPercent < 0.75 or (math.ceil(playStage.framesPassed/(switchPercent > 0.9 and 3 or 6))%2 == 0) then
                    -- if switchPercent > 0.9 then
                    --     timer2rainbow(gc,playStage.framesPassed+150,20)
                    -- else
                        gc:setColorRGB(14, 28, 164) --dark blue
                    -- end

                    gc:drawRect(barX - 2, barY - 2, barWidth + 3, barHeight + 3)
                end

                -- if switchPercent < 0.9 then
                    gc:setColorRGB(94, 94, 255) --light blue
                -- end

                gc:fillRect(barX, barY, fillWidth, barHeight)

                -- drawFont(gc, "P", barX - 7, barY + (barHeight / 2) - 3, "centre")
                drawFont(gc, "P", barX + barWidth / 2, barY - 8, "centre")
            end
        end

        gui:detectPos(0,8)

    --debug stuff
        if _DEBUG_ then --this is very messy and a complete clusterf*ck
            Profiler:start("playStage:paint debug", true, "playStage:paint drawing")
            
            local highlightedx=pixel2plot(mouse.x,mouse.y-8)[1]
            local highlightedy=pixel2plot(mouse.x,mouse.y-8)[2]
            local pixels = plot2pixel(highlightedx,highlightedy,true)
            gc:setColorRGB(255,255,100) 
            local ID=blockSelectionListTEMP[(blockSelectionTEMP%(#blockSelectionListTEMP))+1]
            local name=""
            if blockIndex[ID]~=nil then
                name=(" ("..blockIndex[ID]["name"]..") ")
            end
            gc:drawString("fps: "..tostring(fps).." select: "..ID..name.." velX: "..mario.vx.." velY: "..mario.vy, 0, 16, top)
            
            gc:drawString("("..(highlightedx-1)..": "..(13-highlightedy)..") despook: "..despook.." entities: "..objAPI:getObjectCount(), 0, 32, top)
            gc:drawString("blockX "..highlightedx.." blockY "..highlightedy.." id: "..plot2ID(highlightedx,highlightedy).." x"..mouse.x.."y"..(mouse.y-8).." mX: "..mario.x.." mY: "..mario.y, 0, 48, top)
            gc:drawString("mem "..collectgarbage("count"), 0, 48+16, top)
            --gc:drawString("("..(highlightedx-1)..": "..(13-highlightedy)..") id: "..plot2ID(highlightedx,highlightedy), 0, 48, top) --this is for translating GreatEd maps

            for i=1,#debugBoxes do
                gc:setColorRGB(math.random(0,255),math.random(0,255),math.random(0,255))
                if debugBoxes[i][5]==true then --NOT global
                    gc:drawRect(debugBoxes[i][1],debugBoxes[i][2]+8,debugBoxes[i][3],debugBoxes[i][4])
                else
                    gc:drawRect(debugBoxes[i][1]-playStage.cameraOffset,debugBoxes[i][2]+8,debugBoxes[i][3],debugBoxes[i][4])
                end
            end
            debugBoxes={}
            timer2rainbow(gc,framesPassed+200,10)
            if ((framesPassed/15)%2) <= 1 then
                gc:setPen("thin","dotted")
            else
                gc:setPen("thin","dashed")
            end
            gc:drawRect(pixels[1],pixels[2]+8,15,15)
            gc:setPen("thin","smooth")
            gc:setColorRGB(255,255,100) 
        end

    --transition
        if playStage.transition>0 then
            Profiler:start("playStage:draw transition", true, "playStage:paint drawing")

            playStage.transition=playStage.transition-1
            gc:setColorRGB(0,0,0)
            gc:fillRect(0,0,160-((20-playStage.transition)*8),212)
            gc:fillRect(160+(20-playStage.transition)*8,0,160-(20-playStage.transition)*8,212)
        end

        Profiler:stop("playStage:paint drawing")
    else
        gc:setColorRGB(0,0,0)
        gc:fillRect(0,0,screenWidth,screenHeight)
        if playStage.load==1 then
            level.current=string2level(level.perm)
            mario:resetPos()
            playStage.cameraOffset=(mario.x<96) and 0 or mario.x-96
            if type(playStage.EDITOR)=="table" then
                mario.x,mario.y=math.round(playStage.EDITOR[1]/16)*16,math.round(playStage.EDITOR[2]/16)*16
                mario.iFrames=playStage.framesPassed+40
                playStage.cameraOffset=editor.cameraOffset
            end playStage.cameraTargetOffset=playStage.cameraOffset
            playStage.levelWidth=((level.current.END)*16)
            playStage:levelLogic()
            mario:logic() mario:teleport(mario.x,mario.y)
        end
        playStage.load=playStage.load+1
        drawFont(gc,"LOADING LEVEL FOR PLAY...", nil, nil,"centre",0)
    end
    __PC.allowedHeldKeys = {
        "down",
        "_dpdown",
        "left",
        "_dpleft",
        "right",
        "_dpright",
    }
end

function playStage:drawCircleTransition(gc,centerX,centerY,frame,out) --out=false/nil, then in. frame values: 1-29
    if out then frame=30-frame end
    --CALCULATE THE VALUE
    local circleSize=280
    local speedValue=24
    for i=1,(frame-1) do
        if speedValue>5 then speedValue=speedValue-1
        else speedValue=speedValue-0.1
        end circleSize=circleSize-(speedValue*0.9)
    end
    gc:setColorRGB(0, 0, 0)
    if frame<0 then
    elseif frame<30 then
        --DRAW CIRCLE
        gc:drawImage(image.copy(texs.transitioncircle_1,circleSize,circleSize),centerX-circleSize,centerY-circleSize)
        gc:drawImage(image.copy(texs.transitioncircle_2,circleSize,circleSize),centerX,centerY-circleSize)
        gc:drawImage(image.copy(texs.transitioncircle_3,circleSize,circleSize),centerX,centerY)
        gc:drawImage(image.copy(texs.transitioncircle_4,circleSize,circleSize),centerX-circleSize,centerY)
        --DRAW BORDERS
        local v1=math.max(0,centerY-circleSize)
        local v2=math.max(0,centerX+circleSize-1)
        gc:fillRect(0,0,screenWidth,v1+1)--top
        gc:fillRect(0,math.max(0,circleSize+centerY)-1,screenWidth,math.max(0,screenHeight-(circleSize+centerY))+2)--bottom
        gc:fillRect(0,v1,math.max(0,centerX-circleSize)+1,circleSize*2)--left
        gc:fillRect(v2,v1,math.max(0,screenWidth-v2),circleSize*2)--right
    else
        gc:fillRect(0,0,screenWidth,screenHeight)
    end
end

function playStage:setEvent(target, value)
    print("playStage:setEvent",target,value,type(value))
    playStage.events[target]=value
end

function playStage:evaluateEventCondition(eventswitch)
    local condition = false

    if eventswitch[2] == "true" then
        condition = not not playStage.events[eventswitch[1]] --is truthy
    elseif eventswitch[2] == "false" then
        condition = not playStage.events[eventswitch[1]] --is falsy
    else
        condition = playStage.events[eventswitch[1]] == eventswitch[2]
    end

    return condition
end

function playStage:playBGM()
    local theme = pixel2theme(mario.x+8,true)

    if playStage.events.pswitch then
        theme = 201
    elseif mario.starTimer>playStage.framesPassed then
        theme = 200
    end

    if playStage.TIME <= 100 then
        theme = theme + 100
        if not playStage.playedHurry then
            theme = 1000
        end
    end
    -- print(theme)

    if (((not mario.pipe) or theme==1000) and (not mario.clear)) then
        if playStage.currentBGM~=theme then
            playStage.currentBGM=theme
            local theme2bgm = {
                ["0"] = "overworld",
                ["1"] = "underground",
                ["2"] = "night",
                ["3"] = "castle",
                ["200"] = "star",
                ["201"] = "pswitch",
                ["100"] = "overworldhurry",
                ["101"] = "undergroundhurry",
                ["102"] = "nighthurry",
                ["103"] = "castlehurry",
                ["300"] = "starhurry",
                ["301"] = "pswitchhurry",
                ["1000"] = "hurry",
            }
            __PC.SOUND:bgm(theme2bgm[tostring(theme)])
        end
    end

    return theme
end