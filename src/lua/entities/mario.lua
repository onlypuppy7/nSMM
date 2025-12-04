mario=class(objAPI)

function mario:init()
    mario.trail={}
    self.objectID="mario" self.canCollectCoins=true
    mario:resetPos()
end

function mario:resetPos() --default config
    mario.powerUp=false
    mario.powerDown=false
    mario.clear=false
    mario.dead=false
    mario.powerAnimTimer=0
    mario.dir="R"
    mario.crouch=false
    mario.x=level.current.startX mario.y=level.current.startY
    mario.w=16 mario.h=16
    mario.vx=0 mario.vy=0
    mario.status="idle"
    mario.power=0 mario.skipAnim=false
    playStage.wait=false
    mario.iFrames=-1
    mario.hitCount=0
    mario.starAnim=false
    mario.actionAnimTimer=0
    mario.starTimer=0 mario.interactSpring=true
    mario.jumpAnim=0 mario.spring=false mario.pipe=false
end

function mario:logic() --direction is seperate as its still needed during pause
    mario.starAnim=false
    if not playStage.wait and not mario.powerUp and not mario.powerDown then
        if not mario.spring and not mario.clear or mario.clear==true or mario.clear=="count" then
            mario:calculateInput()
            mario:calculateMove()
    end end
    mario:calculateAnim()
end

function mario:calculateInput() --turns inputs into velocity (or crouch/fireball)
    local topSpeed=7
    if level.current.autoMove=="w" then topSpeed=3.5 end
--X movement
    if mario.power~=0 and (input.down==1) and mario.vy==0 then
        mario.crouch=true mario.actionAnimTimer=0
    elseif mario.power~=0 and mario.vy==0 and self:bumpCheck(-1,true) then
        mario.crouch=true mario.actionAnimTimer=0
    elseif mario.vy==0 or mario.power==0 then mario.crouch=false end
    if input.down==1 and mario.vy==0 then mario:pipeCheck() end
    if mario.crouch then mario.vx=mario.vx*(0.93) end
    if mario.crouch and mario.vy==0 and (pixel2solid(mario.x+2-playStage.cameraOffset,mario.y-8) or pixel2solid(mario.x+13-playStage.cameraOffset,mario.y-8)) then
        if mario.jumpAnim>-7 and math.abs(mario.vx)<1 then
            if input.right==1 and (mario.vx>0 or mario.jumpAnim>-1) then mario.vx=input.right
            elseif input.left==1 and (mario.vx<0 or mario.jumpAnim>-1) then mario.vx=-input.left end
        end
    elseif (input.left==1 or input.right==1) and (not mario.crouch or mario.vy~=0) then
        if ((input.left==1 and mario.vx>0.5) or (input.right==1 and mario.vx<-0.5)) and mario.vy==0 then
            mario.vx=mario.vx*0.9 --drifting slower
            __PC.SOUND:sfx("skid", true)
        else --not drifting
        --max running speed 7
            if math.abs(mario.vx)<2.0 then --walking under 2.0
                mario.vx=mario.vx+input.right*(math.random(3,5)/10)
                mario.vx=mario.vx-input.left*(math.random(3,5)/10)
            elseif math.abs(mario.vx)<4.5 then
                mario.vx=mario.vx+input.right*0.3
                mario.vx=mario.vx-input.left*0.3
            elseif math.abs(mario.vx)<=topSpeed and mario.vy==0 then
                mario.vx=mario.vx+input.right*0.12
                mario.vx=mario.vx-input.left*0.12
            elseif math.abs(mario.vx)<=topSpeed and mario.vy~=0 and ((input.right==1 and mario.vx<-0.5) or (input.left==1 and mario.vx>0.5)) then
                mario.vx=mario.vx+input.right*0.6
                mario.vx=mario.vx-input.left*0.6 end end
    elseif not mario.crouch then -- not holding inputs
        if mario.vy==0 then mario.vx=mario.vx*(0.8) -- on ground
        else mario.vx=mario.vx*(0.95) end -- in air
    end
    if mario.vx>=topSpeed then mario.vx=topSpeed elseif mario.vx<=-topSpeed then mario.vx=-topSpeed end 
    if math.abs(mario.vx)<0.1 then mario.vx=0 end --movement minumum, prevents velocity of 0.00001626 for example
--Y movement
    if input.up==1 and self.vy==0 and self:gravityCheck(0,true,true) and not playStage.disableJumping then  --up arrow pressed and on the floor (no double jumps)
        local runningBoost=(math.abs(mario.vx)>3) and math.abs(mario.vx) or 0
        mario.jumpAnim=(mario.jumpAnim<=0) and 3 or mario.jumpAnim
        self.vy=18+runningBoost--for a maximum of 25, jump ~5.5 blocks. without boost is 4 blocks (idle)
        if mario.power==0 then
            __PC.SOUND:sfx("jump1")
        else
            __PC.SOUND:sfx("jump2")
        end
    else mario.vy=(mario.vy>0) and mario.vy*0.745 or mario.vy end --slow down upwards velocity when jumping (lower is floatier)
    mario.vy=(math.abs(mario.vy)<0.6) and 0 or mario.vy --movement minumum, prevents velocity of 0.00001626 for example
--SPECIAL ACTIONS
    if input.action==1 and mario.power==2 and not mario.crouch then
        local fireballCount=0
        for _, particleName in ipairs(entityLists.particle) do
            if string.match(particleName, "fireball") then
                fireballCount = fireballCount + 1
            end
        end
        if fireballCount<2 then
            mario.actionAnimTimer=2
            if mario.dir=="L" then objAPI:createObj("fireball_L",mario.x,mario.y)
            else objAPI:createObj("fireball_R",mario.x+8,mario.y)
end end end end

function mario:calculateMove() --use velocity to update position
    if mario.vtempY ~= nil then
        mario.vy=mario.vtempY
        mario.vtempY=nil
    end
    mario.vx=math.round(mario.vx,2)
    mario.vy=math.round(mario.vy,2)
--X handling
    self:aggregateCheckX(mario.px,true) --check & confirm platform's velocity
    self:aggregateCheckX(mario.vx) --check & confirm mario's velocity
    local rightSideTolerance=305+4
    if (mario.x<0) or (((mario.x)<playStage.cameraOffset-2) and (level.current.autoScroll or level.current.disableBackScrolling)) then --left side
        mario.x=playStage.cameraOffset-2 if mario.vx<0 then mario.vx=0 end
        if self:multiWallCheck({{13,1},{13,15}}) then mario:kill() end
        if (mario.power>0 and not mario.crouch) and self:multiWallCheck({{13,-13} or nil}) then mario:kill() end
    elseif (mario.x>(playStage.levelWidth-13)) or (((mario.x)-playStage.cameraOffset>rightSideTolerance) and (level.current.autoScroll)) then --right side
        mario.x=rightSideTolerance+math.ceil(playStage.cameraOffset) if mario.vx>0 then mario.vx=0 end
        if self:multiWallCheck({{2,1},{2,15},(mario.power>0) and {2,-13} or nil}) then mario:kill() end
        if (mario.power>0 and not mario.crouch) and self:multiWallCheck({{2,-13} or nil}) then mario:kill() end
    end
--Y handling
    if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
    if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy) end
--OTHER (death plane)
    self:checkFor()
    if mario.y>216 then mario:kill() end
    mario:setNewPushV()
end

function mario:calculateAnim(calculateAnimForce) --handles mario's visuals (walk cycles, animations etc)
    if (not mario.powerUp and not mario.powerDown and not playStage.wait and not mario.clear and not mario.dead) or calculateAnimForce or mario.pipe then --normal gameplay
        mario.powerAnim=mario.power
        if not mario.crouch then
            if mario.vy==0 then
                if mario.vx~=0 then
                    local velocity2cycle=0
                    if (math.abs(mario.vx))>6.5 then velocity2cycle = 1.2 elseif (math.abs(mario.vx))>4.5 then velocity2cycle = 0.6 elseif (math.abs(mario.vx))>2 then velocity2cycle = 0.3 else velocity2cycle = 0.2 end
                    mario.status="walk"..math.floor((velocity2cycle*mario.framesPassed)%3)+1 end
                if input.left==1 and mario.vx>0 then mario.status="drift" input.right=0 --drift animation if arrow key is going opposite way to velocity
                elseif input.right==1 and mario.vx<0 then mario.status="drift" input.left=0 end
                if mario.vx==0 then mario.status="idle" end
                else mario.status="jump"
            end
        else mario.status="crouch"
        end
        if mario.actionAnimTimer>0 then
            mario.actionAnimTimer=mario.actionAnimTimer-1
            mario.status="fire"
        end
    elseif mario.powerUp and playStage.wait then --powering UP in progress
        if mario.power==1 then --growing to big mario
            if playStage.framesPassedBlock-12<mario.powerAnimTimer then 
                local animOption=(math.ceil((playStage.framesPassedBlock/2)))%2
                if animOption==1 then mario.powerAnim=1 mario.status="grow" else mario.powerAnim=0 mario.status="idle" end
            else
                local animOption=(math.ceil((playStage.framesPassedBlock/2)))%3
                if animOption==0 then mario.powerAnim=0 mario.status="idle" elseif animOption==1 then mario.powerAnim=1 mario.status="grow" else mario.powerAnim=1 mario.status="idle" end
            end
        elseif mario.power==2 then --growing to fire mario
            local animOption=(math.ceil((playStage.framesPassedBlock/2)))%4
            mario.powerAnim=2
            mario.starAnim=2
        end
        if playStage.framesPassedBlock-24>mario.powerAnimTimer then --end animation
            mario.powerUp=false
            playStage.wait=false
            mario.starAnim=false
        end
    elseif mario.powerDown and playStage.wait then --powering DOWN in progress
        if mario.power==0 then
            local animOption=(math.ceil((playStage.framesPassedBlock/(flashingDelay*2))))%2
            if playStage.framesPassedBlock-12<mario.powerAnimTimer then --powering down to small mario
                if animOption==1 then mario.powerAnim=mario.power+1 mario.status=mario.animCache else mario.powerAnim=mario.power+1 mario.status="invisible" end --flash
            else --down to big
                mario.animCache=mario.animCache=="crouch" and "walk1" or mario.animCache
                if animOption==1 then mario.status=mario.animCache else mario.status="invisible" end --flash
                mario.powerAnim=mario.power
            end
        elseif mario.power==1 then --powering down to big mario
            local animOption=(math.ceil((playStage.framesPassedBlock/3)))%2
            if animOption==1 then
                mario.powerAnim=1
            else
                mario.powerAnim=2
            end
        end
        if playStage.framesPassedBlock-24>mario.powerAnimTimer then --end power down anim
            mario.powerDown=false
            playStage.wait=false
            mario.iFrames=playStage.framesPassed+40
        end
    elseif mario.clear then --mario cleared animation
        if type(mario.clear)=="table" then --mario turned around on flagpole
            if mario.clear[1]<=playStage.framesPassed then
                mario.clear=true mario.clearedTimer=true
                mario.dir="R"
            end
        elseif mario.clear=="count" then --mario disappeared/stop walking
            if (playStage.TIME-7)>=7 then
                playStage.SCORE=playStage.SCORE+350
                playStage.TIME=playStage.TIME-7
                __PC.SOUND:sfx("timer", true)
            elseif playStage.TIME>0 then
                playStage.SCORE=playStage.SCORE+50*playStage.TIME
                playStage.TIME=0 playStage.clearedTimer=playStage.framesPassed+25
            elseif playStage.clearedTimer<=playStage.framesPassed then
                playStage:completeStage("goal")
            end
        elseif mario.clear==true then --mario walking from flagpole
            if not playStage.wait then mario:calculateAnim(true) end
            if mario.clearedTimer==true then
                if mario.vy==0 then
                    mario.clearedTimer=playStage.framesPassed+31
                    level.current.autoMove="w"
                    if mario.skipAnim then mario:kill()
                    else mario.dir="R" end
                end
            elseif mario.clearedTimer<=playStage.framesPassed then mario:kill()
            end
            if pixel2ID(mario.x,mario.y+8,true)==85 or pixel2ID(mario.x,mario.y+8,true)==86 then --castle door tiles
                mario:kill() mario.y=300 --hide him
            end
        elseif (mario.y+4)<mario.clear then mario.y=mario.y+4  --mario sliding down flagpole
            mario.status="climb"..math.floor((0.5*playStage.framesPassed)%2)+1
        else mario.y=mario.clear --mario at bottom of flagpole
            mario.status="climb2"
        end
    elseif mario.dead then --mario death animation
        mario.powerAnim=0
        if mario.vdeath<-0.5 and (playStage.framesPassedBlock>mario.deathAnimTimer+12) then
            mario.y=mario.y+mario.vdeath
            mario.vdeath=(mario.vdeath+0.2)*0.8
        elseif (mario.vdeath<0 and mario.vdeath>-0.5) or mario.vdeath>0 then
            mario.vdeath=(math.abs(mario.vdeath)+0.3)*1.09
            mario.y=mario.y+mario.vdeath
        end
        if mario.y>220 then
            if not mario.respawnTime then
                mario.respawnTime=playStage.framesPassedBlock+18
            end
            if playStage.framesPassedBlock>mario.respawnTime then playStage:completeStage("dead")
    end end end
    if mario.pipe then
        local pipeActions={ --{x/y, speed, set vx to (anim purposes), move x from pipeX, move y from pipeY}
            {"x",1.5,5,3,0,"L"}, --left
            {"y",1.5,0,8,0.5,"R"}, --up
            {"x",-1.5,-5,-1,0,"R"}, --right
            {"x",0,0,0,0,"R"} --teleport (exit)
        }
        local function limit(num,lim) if num>lim then num=lim end return num end
        local TYPE=level.current.pipeData[mario.pipe[1]][mario.pipe[2]][3]
        pipeActions=pipeActions[TYPE]
        mario.pipe[5]=mario.pipe[5]+1 --timer
        local pipeTime=mario.pipe[5]
        
        if pipeTime<=11 then --init enter pipe, small zoom
            mario[pipeActions[1]]=mario[pipeActions[1]]+pipeActions[2]
            mario.vx=pipeActions[3]
            mario.pipe[6]=limit(mario.pipe[6]+1,6) --transition timer
        elseif pipeTime<=26 then --complete zoom and show black
            mario.pipe[6]=mario.pipe[6]+0.35 --transition timer
        elseif pipeTime==27 then --swap initial entr/exit with opposite
            mario.pipe[2]=mario.pipe[3] --could have just done 3-value here tbh, too late. cant be bothered
        elseif pipeTime==28 then --perform any mid-transition calculation
            mario.pipe[6]=7.5
            local pipeX,pipeY=(level.current.pipeData[mario.pipe[1]][mario.pipe[2]][1]-1)*16,212-16*level.current.pipeData[mario.pipe[1]][mario.pipe[2]][2]
            -- print(pipeX,pipeY,"|",TYPE)
            mario.vx=0 mario.vy=0
            mario.dir=pipeActions[6]
            mario:teleport(pipeX+pipeActions[4],pipeY+pipeActions[5])
            for i=1,#level.current.loadedObjects do
                plot2place(unpack(level.current.loadedObjects[i]))
            end
            level.current.loadedObjects={}
            playStage:clearEntities()
            -- mario[pipeActions[1]]=mario[pipeActions[1]]+pipeActions[2]*11
            __PC.SOUND:sfx("warp")
            local theme = playStage:playBGM()
            if theme~=playStage.currentBGM then
                __PC.SOUND:stopBGM()
            end
            -- playStage.currentBGM=false
            -- __PC.SOUND:stopBGM()
        elseif pipeTime<=39 then --zoom small out again
            mario[pipeActions[1]]=mario[pipeActions[1]]-pipeActions[2]
            if pipeTime<=32 then
                mario.pipe[6]=-limit(-(mario.pipe[6]-0.35),-6) --transition timer
            elseif pipeTime>=35 then
                mario.pipe[6]=mario.pipe[6]-1.25 --transition timer
            end
            if pipeTime==39 then --return game to playing state
                mario.pipe=false playStage.wait=false
                playStage.transition2=false
                __PC.SOUND:pauseBGM(false)
            end
        end
        playStage.transition2=mario.pipe and {mario.x-playStage.cameraOffset+8,mario.y+8,mario.pipe[6]*4} or false
    end
    if (mario.starTimer>playStage.framesPassed) then --handle star anim and hitbox
        if not playStage.wait then
            if (mario.starTimer-70>playStage.framesPassed) then
                mario.starAnim=2
            elseif (mario.starTimer-15>playStage.framesPassed) then
                mario.starAnim=5 --slow down anim
            end
        end
        local h=(mario.power>0) and 16 or 0 --mario height
        objAPI:addHitBox("mario",mario.x,mario.y-h,16,16+h,"mario")
    end
    if not playStage.wait and not mario.clear and not mario.powerUp and not mario.powerDown and (mario.jumpAnim>0 or (not (mario.crouch and (pixel2ID(mario.x+2-playStage.cameraOffset,mario.y-8)==1 or pixel2ID(mario.x+13-playStage.cameraOffset,mario.y-8)==1)) and not self:aggregateCheckX(0,true,true))) and mario.vy==0 then --on ground, not jumping
        if input.right==1 then mario.dir="R"
        elseif input.left==1 then mario.dir="L" end
    end
end

function mario:clearedLevel(xy)
    if type(xy)=="table" then --sliding anim and such
        mario.clear=xy[1] mario.status="climb1"
        mario.x=xy[2]
    else
        mario.clear=true mario.clearedTimer=true mario.skipAnim=xy
    end mario.vx=0 mario.vy=-0.1
    __PC.SOUND:bgm("levelclear")
end

function mario:powerUpMario(optionalPower,forced)
    if not mario.dead and not mario.clear and not mario.powerDown then
        local proceed=true
        if optionalPower~=nil and (forced==true or optionalPower>mario.power) then
            mario.power=optionalPower
        elseif optionalPower==nil and mario.power<2 then mario.power=mario.power+1
        else proceed=false end --there is nothing to power to
        if proceed then
            playStage.wait=true
            mario.powerUp=true
            mario.powerDown=false
            mario.powerAnimTimer=playStage.framesPassedBlock
            mario:calculateAnim(true)
        end
        __PC.SOUND:sfx("powerup")
    end
end

function mario:powerDownMario(optionalPower)
    if mario.power>0 and not mario.dead and not mario.clear and not mario.powerDown and not mario.powerUp and not (mario.iFrames>playStage.framesPassed) then
        mario.power=mario.power-1
        playStage.wait=true
        mario.powerDown=true mario.powerUp=false mario.iFrames=-1
        mario.powerAnimTimer=playStage.framesPassedBlock
        mario.animCache= mario.status=="invisible" and mario.animCache or mario.status --cant be invisible during it
        __PC.SOUND:sfx("warp")
    elseif not mario.dead and not mario.clear and not (mario.iFrames>playStage.framesPassed) and not mario.powerDown and mario.power==0 then
        mario.kill()
    end
end

function mario:powerStarMario(optionalLength)
    if optionalLength==nil then
        mario.starTimer=playStage.framesPassed+200
    else
        mario.starTimer=playStage.framesPassed+optionalLength
    end
    playStage.currentBGM=false
end

function mario:kill()
    if mario.clear then
        level.current.autoMove=nil mario.clear="count"
        if mario.vy==0 then mario.status="idle" self.vx=0
            if not mario.skipAnim then mario.dir="L" end
        end
    else
        mario.vdeath=-11
        mario.respawnTime=false
        mario.status="death"
        playStage.wait=true
        mario.powerDown=false
        mario.powerUp=false
        mario.dead=true
        mario.power=0 mario.powerAnim=0
        mario.jumpAnim=0
        mario.deathAnimTimer=playStage.framesPassedBlock
        __PC.SOUND:bgm("die")
end end

function mario:teleport(x,y)
    local searchL,searchR,wait,offset=mario.x,mario.x,playStage.wait,0.001
    mario.x,mario.y=x,y
    playStage.cameraOffset=mario.x-151
    playStage.cameraBias=30
    playStage.wait=false
    for i=#level.current.scrollStopL,1,-1 do
        if ((mario.x+8)>level.current.scrollStopL[i]) then
            searchL=(level.current.scrollStopL[i]+122)-mario.x
            -- if searchL>159 then searchL=x end
            break
    end end
    for i=1,#level.current.scrollStopR do
        if ((mario.x+8)<level.current.scrollStopR[i]) then
            searchR=((8/7)*mario.x)-(1318/7)
            break
    end end
    if searchL<searchR then searchR=-searchL offset=-offset end
    mario.x=x-searchR
    playStage:scrollCamera(0.995) print(playStage.cameraOffset,playStage.cameraTargetOffset)
    mario.x,mario.y=x,y
    playStage:scrollCamera(0.995) print(playStage.cameraOffset,playStage.cameraTargetOffset)
    playStage.wait=wait
end

function mario:pipeCheck() --print("000000000000")
    if (not (playStage.wait or mario.dead or mario.powerDown or mario.powerUp or mario.clear)) and (mario.vy==0 and (input.down or mario.vx==0)) then --this is starting to become a mess, lol. perhaps more hindsight would be better......
        local success=false --print(self:gravityCheck(self.vy,true,true))
        local function rndPos(v,n) n=n or 16 return math.floor((v+(n/2))/n)*n end
        for pipeID=1,#level.current.pipeData do --cycle thru all pipes
            local pipe=level.current.pipeData[pipeID] --less typing
            for i=1,2 do --entrance, exit
                local TYPE=pipe[i][3]
                local x,y=(pipe[i][1]-1)*16,212-16*(pipe[i][2])
                local mX,mY=rndPos(mario.x),rndPos(mario.y)+4 --mario x, mario y.. this is surely not too cryptic?
                -- print("entrance, exit",pipeID,"pipeID,x,y,TYPE,mario.x,mario.y",pipeID,x,y,TYPE,mario.x,mario.y)
                if input.down and TYPE==2 and self:gravityCheck(self.vy,true,true) then --pipe ID 2 (pipe facing up)
                    if ((rndPos(mario.x-8,8)==x) and ((mY+16)==y)) then --yeah you gotta stand in the middle 16 pixels of the 32 on the pipe top
                        success=true mario.vx=0
                    end
                elseif input.stor.right>=4 and mario.dir=="R" and TYPE==1 and self:gravityCheck(self.vy,true,true) then --pipe ID 1 (pipe facing left) [assumes bumped into wall]
                    if (((mX+16)==x) and (mY==y)) then --same x and y (plus or minus 8 px)
                        success=true
                    end
                elseif input.stor.left>=4 and mario.dir=="L" and TYPE==3 and self:gravityCheck(self.vy,true,true) then --pipe ID 3 (pipe facing right) [assumes bumped into wall]
                    if ((mX==(x+16)) and (mY==y)) then --same x and y (plus or minus 8 px)
                        success=true
                    end
                end
                if success==true then
                    -- print(pipeID,"|",x,y,"|",TYPE,"|",mario.x,mario.y,"|",mX,mY)
                    mario.pipe={pipeID,i,3-i,"enter",0,0} --pipeID, initial entr/exit, depart entr/exit, state, timer, transition timer
                    playStage.wait=true
                    success=false
                    __PC.SOUND:sfx("warp")
                    -- __PC.SOUND:pauseBGM(true)
                end
            end
        end
    end
end

function mario:draw(gc)
    local drawOffset=0
    local star=""
    if mario.powerAnim~=0 then drawOffset=16 end
    if mario.jumpAnim>-7 then 
        if mario.jumpAnim>1 then --literally just so that he makes contact with the floor if jump is held. i know, animating a fake jump that isnt even happening
            if not mario.crouch then mario.status="jump" end
            drawOffset=drawOffset+2
        end
        mario.jumpAnim=mario.jumpAnim-1 
    end
    if mario.starAnim~=false then
        local animOption=(math.ceil((playStage.framesPassedBlock/mario.starAnim)))%4
        if animOption~=3 then
            if mario.powerAnim>0 then
                mario.powerAnim=2
            else
                mario.powerAnim=0
            end
            star="star"..animOption
        end
    end
    if mario.iFrames>playStage.framesPassed and not playStage.wait and not mario.powerUp and not mario.powerDown then --currently under influence of iframes
        local animOption=(math.ceil((playStage.framesPassed/flashingDelay)))%2
        if animOption==1 then mario.animCache=mario.status mario.status="invisible" end
    end
    local status=mario.dir..((star=="" or mario.powerAnim<=1) and mario.powerAnim or "1")..mario.status..star
    if playStage.EDITOR and not playStage.wait and not mario.powerUp and not mario.powerDown and mario.status~="invisible" then
        table.insert(mario.trail,1,{status,mario.x,mario.y-drawOffset+8})
        mario.trail[41]=nil --prevent list from becoming too long, if you increase this then the trail gets longer...
    end
    if mario.status~="invisible" then
        gc:drawImage(texs[status],mario.x-playStage.cameraOffset,mario.y-drawOffset+8) --draw... mario.
    end
end

function mario:handleStomp()
    mario.hitCount=mario.hitCount+1
    if mario.hitCount~=0 then
        if mario.hitCount<#hitProgressionMario+1 then
            objAPI:addStats("points",hitProgressionMario[mario.hitCount],mario.x,mario.y-16)
        else --1up
            objAPI:addStats("1up",1,mario.x,mario.y-16)
        end
    end
end