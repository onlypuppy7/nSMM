objAPI=class() --categories are only roughly representative
--DEFAULT VALUES
objAPI.dead=false objAPI.px=0 objAPI.py=0
objAPI.spring=false objAPI.interactSpring=true

function objAPI:initObject(objectID,TYPE,LEVEL,hitBox,xywh,vx,vy) --facilitates bringing an object into existence!
    self.objectID=objectID
    self.TYPE=TYPE
    self.LEVEL=LEVEL or "inner"
    self.hitBox=hitBox
    self.x=xywh[1] self.y=xywh[2] self.w=xywh[3] or 16 self.h=xywh[4] or 16 self.vy=vy or 0
    self.vx=(vx~=true) and vx or ((mario.x>self.x) and 2 or -2)
end

--OBJECT/PLATFORM MANAGEMENT
function objAPI:getObjectCount(passedEntityLists) --returns the number of objects in a given level
    local entityLists=passedEntityLists or entityLists
    local count=0
    for k in pairs(entityLists) do
        count=count+#entityLists[k]
    end
    return count
end

function objAPI:createObj(TYPE,posX,posY,despawnable,arg1,arg2)
    --todo, rename objectID to objectID because class makes no sense here
    local objectID=TYPE..objAPI:getObjectCount()+1+framesPassed.."r"..math.random(0,200) --assign random ID
    local classTYPE local LEVEL
    classTYPE,LEVEL=objAPI:type2class(TYPE)
    local levelObject=entityLists[LEVEL]
    if classTYPE~=false then
        allEntities[objectID]=entityClasses[classTYPE]()  --despawnable also triggers block animation (sometimes) [edit idfk why i made this comment here]
        table.insert(levelObject,objectID)
        allEntities[objectID]:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
    end return objectID
end

function objAPI:destroyObject(objectName,LEVEL) --add to cleanup waitlist
    table.insert(cleanupListDestroy,{objectName,LEVEL})
end

function objAPI:destroy()
    objAPI:destroyObject(self.objectID,self.LEVEL)
end

function objAPI:transferLayer(objectName,LEVEL,newLEVEL) --add to cleanup waitlist
    table.insert(cleanupListTransfer,{objectName,LEVEL,newLEVEL})
end

function objAPI:sendToFront(objectName,LEVEL) --removes from layer and reinserts at the top
    table.insert(cleanupListTransfer,{objectName,LEVEL,LEVEL})
end

function objAPI:addHitBox(objectID,x,y,w,h,TYPE)
    table.insert(hitBoxList,{objectID,x,y,w,h,TYPE})
end

function objAPI:addPlatform(x,y,w,xVel,yVel)
    local yOffset=0
    if math.abs(yVel)>1 then
        yOffset=(math.floor(y-4)%2)
    end
    table.insert(playStage.platformListAdd,{self.objectID,x,y-yOffset,w,xVel,yVel})
end

function objAPI:updatePlatforms()
    playStage.platformList={}
    for i=1,#playStage.platformListAdd do
        table.insert(playStage.platformList,{unpack(playStage.platformListAdd[i])})
    end
    playStage.platformListAdd={}
end

function objAPI:cleanup() --these huge functions relating to every object are very fun :>
    for iH=1,#hitBoxList do --hitBox aggressor array: {objectID,x,y,w,h,type} // hitBox passive array: {w,h,willBeKilled,destroyFireball,xOffset,yOffset}
        for k in pairs(entityLists) do --do all entity lists
            local focusedList=entityLists[k]
            for i=1,#focusedList do --for all entities within the list
                local entity=allEntities[focusedList[i]]

                if entity.hitBox then --if entity can be hit
                    local victomHitBox=entity.hitBox
                    local aggressorHitBox=hitBoxList[iH]
                    victomHitBox[5],victomHitBox[6]=victomHitBox[5] or 0,victomHitBox[6] or 0
                    -- local pos={entity.x,entity.y} -- V if there is a collision V

                    if aggressorHitBox[1]~=entity.objectID and (checkCollision(aggressorHitBox[2],aggressorHitBox[3],aggressorHitBox[4],aggressorHitBox[5],entity.x+2+victomHitBox[5],entity.y+2+victomHitBox[6],victomHitBox[1]-4,victomHitBox[2]-4)) then
                        if entity.dead~=true then
                            local hitVictim=allEntities[aggressorHitBox[1]]

                            print("HIT",aggressorHitBox[1],entity.objectID,victomHitBox[1],victomHitBox[2],victomHitBox[3],victomHitBox[4],aggressorHitBox[2],aggressorHitBox[3],aggressorHitBox[4],aggressorHitBox[5],aggressorHitBox[6])
                            
                            if aggressorHitBox[6]=="shell" and victomHitBox[3]==true then
                                hitVictim:handleShellPoints()
                                if entity.destroyShell then hitVictim:hit() end
                            elseif aggressorHitBox[6]=="fireball" and victomHitBox[4]==true then
                                hitVictim:handleFireballHit()
                            elseif aggressorHitBox[6]=="mario" and not entity.disableStarPoints then
                                objAPI:addStats("points","200",mario.x,mario.y-16)
                            end
                        end
                        entity:hit(aggressorHitBox[6]) --react to hit (death/jump/other)
    end end end end end --important for hitbox to go first so that new queued requests don't get cleared
    for i=1,#cleanupListDestroy do --remove entity from list and clear all stored vars
        local objectName,LEVEL=unpack(cleanupListDestroy[i])
        -- print(objectName,LEVEL)
        local levelObject=entityLists[LEVEL]
        for i2=1,#levelObject do
            if levelObject[i2]==objectName then
                table.remove(levelObject,i2)
                allEntities[objectName]={}
                break
    end end end
    for i=1,#cleanupListTransfer do
        local LEVEL=cleanupListTransfer[i][2]
        local newLEVEL=cleanupListTransfer[i][3]
        local objectName=cleanupListTransfer[i][1]
        local levelObject=entityLists[LEVEL]
        local newLevelObject=entityLists[newLEVEL]
        for i2=1,#levelObject do
            if levelObject[i2]==objectName then
                table.remove(levelObject,i2)
                table.insert(newLevelObject,objectName)
                break
    end end end

    cleanupListDestroy={}
    cleanupListTransfer={}
    hitBoxList={}
end

function objAPI:getBlockStandingOn() --returns the block that the entity is standing on, if any
    local rightX=self.x+self.w
    local bottomY=self.y+self.h

    local blockLeft=pixel2block(self.x,bottomY,true)
    local blockRight=pixel2block(rightX,bottomY,true)

    blockLeft=(blockLeft and self:checkForWall(self.x,bottomY)) and blockLeft or false
    blockRight=(blockRight and self:checkForWall(rightX,bottomY)) and blockRight or false

    -- print("blockLeft",blockLeft,blockRight)

    local pushVLeft=blockLeft and blockLeft.pushV or 0

    local block

    if blockLeft and blockRight then
        --go in the center of the block
        local blockCenter=pixel2block(self.x+(self.w/2),bottomY,true)
        block=blockCenter or false
    else 
        block=blockLeft or blockRight
    end

    return block
end

function objAPI:setNewPushV()
    local px,py=0,0
    if not self.spring then --a somewhat embarrasing solution...
        local platformVel=objAPI:platformCheck(self.x,self.y)
        if platformVel then
            px,py=platformVel[1],platformVel[2]
        end
    end
    local blockStandingOn=self:getBlockStandingOn()
    if blockStandingOn and blockStandingOn.pushV then
        px=px+blockStandingOn.pushV
    end
    self.px=px
    self.py=py
end

function objAPI:addStats(type,value,x,y,fromFlagpole)
    if type=="points" then
        if x~=nil and y~=nil then objAPI:createObj("score",x,y,nil,value) end --particle
        playStage.SCORE=playStage.SCORE+value
    elseif type=="coins" then
        playStage.coinCount=playStage.coinCount+value
        if playStage.coinCount>99 then
            playStage.coinCount=playStage.coinCount%100
            objAPI:addStats("1up",1,mario.x,mario.y)
        end
    elseif type=="1up" and x~=nil and y~=nil then
        objAPI:createObj("score",x,y,nil,"1up")
    end
end

--OBJECT ANIMATION
function objAPI:animateDeathFlyOffscreen()
    self.x=self.x+self.vx
    if self.vy<-0.5 then --rising
        self.vy=(self.vy+0.25)*0.75 --most of these values do not have much meaning, just tuned to what feels right :>
    elseif (self.vy<0 and self.vy>-0.5) or self.vy>0 then --begin/is falling
        self.vy=self.vy>6 and 6 or (math.abs(self.vy)+0.5)*1.18
    end
    self.y=self.y+self.vy
    if self.y<0 then
        self:destroy()
    end
end --NEW code approved

--OBJECT MOVEMENT
function objAPI:checkForWall(x,y,isMario) -- return true if point is in wall
    local isMario=isMario or (self.objectID=="mario")
    return (pixel2solid(x,y,true) and not (isMario and pixel2anything("marioonly",x,y,true))) or (isMario and pixel2anything("entityonly",x,y,true)) --check if x pos in a wall
end --NEW code approved

function objAPI:multiWallCheck(v,notRelative) -- returns true if any point in wall
    local results,r={},not notRelative and {self.x,self.y} or {0,0}
    for i=1,#v do
        results[i]=self:checkForWall(v[i][1]+r[1],v[i][2]+r[2])
    end return table.checkForValue(results,true)
end --NEW code approved

function objAPI:calculateAccelerationY(strength,terminalV)
    if not self.spring then --a somewhat embarrasing solution...
        strength=strength or 1
        local terminalV,dec,acc=terminalV or -6,0.7*strength,1.2*strength
        if self.vy>0 then --ascending
            self.vy=(self.vy>0.5) and self.vy*dec or -0.08
        elseif self.vy<0 then --descending
            self.vy=(self.vy*acc<terminalV) and terminalV or self.vy*acc
end end end --NEW code approved

function objAPI:aggregateCheckX(V,platformCalc) --to move in the x direction
    if not self.spring then --a somewhat embarrasing solution...
        local function rndPos(X,V)
            if V<0 then return (math.floor(X/16))*16
            else return (math.ceil(X/16))*16 end
        end
        local function checkX(X,Y,V,checkSemisolid)
            local result={rndPos(X,V),true}
            if self:checkForWall(X+V,Y) then --wallX becomes true if there is a wall
            elseif checkSemisolid and V<0 and pixel2semisolid(2,X+V,Y,true) then --going left
                local semisolidPos=rndPos(X+V,0) --yea
                if not (((X+V)<=semisolidPos) and (X>=semisolidPos)) then result={X+V,false} end
            elseif checkSemisolid and V>0 and pixel2semisolid(4,X+V,Y,true) then --going right
                local semisolidPos=rndPos(X,V)
                if not (((X+V)>=semisolidPos) and (X<=semisolidPos)) then result={X+V,false} end
            else result={X+V,false} end return unpack(result)
        end
        local X,Y,W,H,V,isMario,LEFT,RIGHT,POWER = self.x,self.y,self.w or 16,self.h or 16,V or self.vx,self.objectID=="mario" and true or false,(V<0),(V>0)
        local powerLeft,powerRight,wall5,wall6,finalPos
        local topLeft,wall1     =checkX(X+2,Y+3,V,LEFT)
        local topRight,wall2    =checkX(X+W-3,Y+3,V,RIGHT)
        local bottomLeft,wall3  =checkX(X+2,Y+H-1,V,LEFT)
        local bottomRight,wall4 =checkX(X+W-3,Y+H-1,V,RIGHT)
        local valuesX={topLeft-2,topRight-W+3,bottomLeft-2,bottomRight-W+3}
        if isMario and mario.power>0 and not mario.crouch then
            powerLeft,wall5     =checkX(X+2,Y-15,V,LEFT)
            powerRight,wall6    =checkX(X+W-3,Y-15,V,RIGHT)
            table.insert(valuesX,powerLeft-2) table.insert(valuesX,powerRight-W+3) 
        end
        if V<0 then finalPos=math.max(unpack(valuesX))
        else        finalPos=math.min(unpack(valuesX)) end
        if wall1 or wall2 or wall3 or wall4 or wall5 or wall6 then --contact with wall made
            local justify=((wall1 or wall3 or wall5) and input.left==1) and "L" or ((wall2 or wall4 or wall6) and input.right==1) and "R" or false
            self:checkFor(justify)
            if isMario and self.vy==0 then mario:pipeCheck() end
            if self.canHitSide and self.vx~=0 then
                local testPos=finalPos+(V>0 and W-3 or 0)+pol2binary(V)*8 local offsetY={1,H-1}
                for i=1,#offsetY do
                    if pixel2bumpable(testPos,self.y+offsetY[i],true) then
                        local v=pixel2plot(testPos,self.y+offsetY[i],true)
                        objAPI:handleBumpedBlock(v[1],v[2],true)
            end end end
            if self.isFireball then self:handleFireballHit() end
            if not platformCalc then
                if isMario and math.round(X,1)==math.round(finalPos,1) then self.vx=0 --print(X,V,self.vx,finalPos)
                elseif self.turnAround then self.vx=-self.vx
        end end end
        self.x=finalPos
end end --NEW code approved

function objAPI:gravityCheck(yVel,platformCalc,jumpCalc) --made to work with velocity values that are reasonable, ie up is negative, down is positive
    if not self.spring then --a somewhat embarrasing solution...
        local function rndPos(Y,V) return (math.floor((Y+V)/16)*16)+4 end --this likely won't work so well with downwards velocities below -15, take note
        local function checkY(isMario,X,Y,V,platformCalc)
            local pos={Y+V} --list of possible positions to fall to
            if not platformCalc then
                for i=1,#playStage.platformList do
                    local platform=playStage.platformList[i]

                    local pX=platform[2] local pY=platform[3] local pW=platform[4] local pV=-platform[6]
                    if X>=pX and X<=pX+pW then --object is in x axis radius of platform, therefore possibility of landing
                        if ((Y<=pY) and (not ((pos[1])<pY) or not ((pos[1])<(pY+pV)))) then --if above platform and not (wont land on it)
                            table.insert(pos,pY) pos[1]=pY
            end end end end
            if (pixel2solid(X,pos[1],true) and not (isMario and pixel2anything("marioonly",X,pos[1],true))) then
                table.insert(pos,rndPos(Y,V)) -- ↳ if block is solid
            elseif (isMario and pixel2anything("entityonly",X,pos[1],true)) then
                table.insert(pos,rndPos(Y,V)) -- ↳ if 1. it is mario 2. if it's entityonly then it is solid for him. necessary as entityonly blocks do not have the general 'solid' parameter
            elseif pixel2semisolid(1,X,pos[1],true) then
                local semisolidPos=rndPos(Y,V)
                if ((Y+V)>=semisolidPos) and (Y<=semisolidPos) then table.insert(pos,semisolidPos) end --MUCH better than my last """solution"""
            end
            local finalPos=math.min(unpack(pos)) local onFloor=(#pos)~=1
            return finalPos, onFloor
        end
        local X,Y,W,H,V,isMario=self.x,math.floor(self.y),self.w or 16,self.h or 16,math.floor(yVel) or -math.ceil(self.vy),self.objectID=="mario" and true or false
        local LEFT, floorL=checkY(isMario,self.x+3,Y+H,V,platformCalc)
        local RIGHT,floorR=checkY(isMario,self.x+W-3,Y+H,V,platformCalc)
        if W>16 then --prevent falling into a block for wide entities. **only works for 32 in this case**
            local RIGHT2,floorR2=checkY(isMario,self.x+16-3,Y+H,V,platformCalc)
            if RIGHT2<RIGHT then
                RIGHT,floorR=RIGHT2,floorR2
        end end
        local finalPos=math.min(LEFT-H,RIGHT-H) --PAY ATTENTION!! the height offset must ALWAYS be considered
        if jumpCalc then
            if self.y==finalPos then return true end
            return false
        end
        if not platformCalc or self.vy==0 then
            if floorL or floorR then
                if self.doesBounce then self.vy=(type(self.doesBounce)=="number" and self.doesBounce) or 17
                -- elseif self.isBouncy and self.vy<0 then
                --     self.vy=-((self.lastBounce or self.vy))
                --     self.lastBounce=-(self.vy)+3.5
                --     if self.vy<0.9 then self.lastBounce=nil self.vy=0 end
                else self.vy=0 end
                if isMario then mario.hitCount=0 end
            else self.vy=math.max(self.vy-1.4,-7)
        end end
        if self.noFall and self.vy==0 and not platformCalc then
            if (floorL and not floorR) or (floorR and not floorL) then
                self.vx=-self.vx
            end
        end
        self.y=finalPos
end end --NEW code approved

function objAPI:bumpCheck(V,crouchCalc) --made to work with velocity values that are reasonable, ie up is negative, down is positive
    if not self.spring then --a somewhat embarrasing solution...
        local function checkY(isMario,X,Y,V)
        local function rndPos(X) return (math.ceil((X-4)/16)*16)+4 end
            for i=(math.floor((Y-4)/16)*16)+3,(Y+V-15),-16 do
                i=(i<(Y+V)) and (Y+V) or i
                if (pixel2solid(X,i,true) and not (isMario and pixel2anything("marioonly",X,i,true))) then
                    return rndPos(i),{X,i} -- ↳ if block is solid
                elseif isMario and pixel2anything("entityonly",X,i,true) then
                    return rndPos(i),{X,i} -- ↳ if 1. it is mario 2. if it's entityonly then it is solid for him. necessary as entityonly blocks do not have the general 'solid' parameter
                elseif isMario and pixel2anything("invisiblock",X,i,true) then
                    return rndPos(i),{X,i}
                elseif pixel2semisolid(3,X,i,true) then
                    local semisolidPos=rndPos(i)
                    if ((Y+V)<=semisolidPos) and (Y>=semisolidPos) then return rndPos(i),{X,i} end
            end end return Y+V,false
        end
        local X,Y,W,H,V,isMario = self.x,self.y,self.w or 16,self.h or 16,V or self.vy,self.objectID=="mario" and true or false
        local offsetY=(isMario and mario.power>0 and not mario.crouch) and -15 or 0
        local topLeft,topLeftB=checkY(isMario,X+3,Y+offsetY,V)
        local topRight,topRightB=checkY(isMario,X+W-3,Y+offsetY,V)
        if crouchCalc and mario.crouch then return not not (topLeftB or topRightB) end --table to boolean :p
        if topLeftB or topRightB then
            self.vy=-0.61
            if self.isFireball then self:handleFireballHit() self.y=self.y-4 return end
            if self.canHit or isMario then
                if type(topLeftB)=="boolean" then topLeftB=topRightB end
                if type(topRightB)=="boolean" then topRightB=topLeftB end
                topLeftB[2],topRightB[2]=math.max(topLeftB[2],topRightB[2]),math.max(topLeftB[2],topRightB[2])
                local bumps={topLeftB,topRightB}
                for i=1,#bumps do
                    if bumps[i] and pixel2bumpable(bumps[i][1],bumps[i][2],true) then
                        objAPI:handleBumpedBlock(unpack(pixel2plot(bumps[i][1],bumps[i][2],true)))
        end end end end
        self.y=math.max(topLeft-offsetY,topRight-offsetY)
end end --NEW code approved

function objAPI:platformCheck(x,y,optionalLength) --checks if standing on a platform and then returns xVel/yVel if applicable
    y=math.floor(y)
    local distance=15-2
    if optionalLength then distance=optionalLength-2 end
    for i=1,#playStage.platformList do 
        local platform=playStage.platformList[i]
        local pX=platform[2] local pY=platform[3] local pW=platform[4]

        if ((x+2>=pX and x+2<=pX+pW) or (x+distance>=pX and x+distance<=pX+pW)) and y+16==pY then --object is in x axis radius of platform, and is on same y level
            return {tonumber(platform[5]),tonumber(platform[6])}
        end
    end
    return {0,0}
end --TODO rewrite needed ##############

--OBJECT BEHAVIOUR
function objAPI:checkStuckInWall()
    if self:checkForWall(self.x+8,self.y+8) and not self.dead then --stuck in a block
        self:destroy()
    end
end --NEW code approved

function objAPI:checkMarioCollision(onStomp,noKill,bodge) bodge=bodge or 0 --bodge is a temporary fix for the fact that bowser's xy center is not the same as his visual appearance and so he can't be hit, very hacky, very bad, very sad, very mad
    if not (mario.starTimer>playStage.framesPassed) or self.allowStarCollision then --hitting mario is possible
        local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
        if onStomp and checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+1,self.y,self.hitBox[1]-1,1) and (mario.vy<0 or mario.py<0 or self.py>0 or self.vy>0) then --hit on head
            if not noKill then
                mario.vtempY=15
                mario:handleStomp()
                self.dead=true -- !! may not always apply
            end
            if onStomp[1]=="stomp" then
                self.status=onStomp[2]
                self.deathAnimTimer=playStage.framesPassed+10
                objAPI:sendToFront(self.objectID,self.LEVEL)
            elseif onStomp[1]=="dropkill" then
                self.vy=0.5
            elseif onStomp[1]=="powerup" then self:use()
            elseif onStomp[1]=="shell" then
                self.hitTimer=playStage.framesPassed+8 --avoid instakill after kicking shell or double hits
                local shakeCondition=self.koopaTimer and (self.koopaTimer-45<playStage.framesPassed)
                if self.vx==0 and not shakeCondition then --NOT shaking (about to turn into koopa)
                    self.koopaTimer=false
                    if level.current.enableShellBouncing==true then mario.vtempY=8 end
                    objAPI:addStats("points",400,self.x,self.y)
                    self.vx=(self.x>mario.x) and 4 or -4
                else self.vx=0 --shaking or moving, outcome is the same either way
                    self.koopaTimer=playStage.framesPassed+200
                    mario.vtempY=15
                    mario:handleStomp() --repeated code! aaah!
                end
            elseif onStomp[1]=="transform" then
                local vx,newID=self.vx,objAPI:createObj(onStomp[2],self.x,self.y,nil,onStomp[3],onStomp[4])
                self:destroy() self.status=onStomp[5]
                if string.sub(self.TYPE,1,5)=="Pkoop" then allEntities[newID].vx=sign(vx)*2 end 
            end
            if level.current.enableCoinOnKill then objAPI:createObj("coin",self.x,self.y-16,true) end
        elseif checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+4,self.y+3+bodge,self.hitBox[1]-8,self.hitBox[2]-4) then --hit mario (side)
            if onStomp[1]=="shell" and self.vx==0 then
                self.hitTimer=playStage.framesPassed+8 --avoid instakill after kicking shell or double hits
                self.koopaTimer=false self.hitCount=0
                objAPI:addStats("points",400,self.x,self.y)
                self.vx=(self.x>mario.x) and 6 or -6
            elseif onStomp[1]=="powerup" then self:use()
            elseif onStomp[1]=="clear" then
                if not mario.clear then mario:clearedLevel(onStomp[2]) playStage.wait=true end
                self.dead=true
            else mario:powerDownMario() end
        end
        --table.insert(debugBoxes,{mario.x+1,mario.y-marioSize+1,14,14+marioSize})
        --table.insert(debugBoxes,{self.x+4,self.y+3+bodge,self.hitBox[1]-8,self.hitBox[2]-4})
    end
end --NEW code approved

function objAPI:handleHitDefault(circumstance,newStatus,newTYPE) --works for most enemies
    self.vy=-11 self.dead=true self.status=newStatus self.TYPE=newTYPE or self.TYPE
    if level.current.enableCoinOnKill then objAPI:createObj("coin",self.x,self.y-16,true) end
    if circumstance=="fireball" or circumstance=="block" then
        objAPI:addStats("points","100",self.x,self.y)
    end
    if circumstance=="mario" or circumstance=="fireball" then
        self.vx=(mario.x<self.x) and 2 or -2
    end objAPI:transferLayer(self.objectID,self.LEVEL,"particle")
    self.LEVEL="particle"
end --NEW code approved

function objAPI:handleBumpedBlock(xLOC,yLOC,shell)
    local ID=plot2ID(xLOC,yLOC)
    local pixelXY=plot2pixel(xLOC,yLOC,false)
    if blockIndex[ID].containing~=nil and blockIndex[ID].containing~=false then --if there is something in the block
        local containing=blockIndex[ID].containing
        if type(containing)=="string" then
            objAPI:createObj(blockIndex[ID].containing,pixelXY[1],pixelXY[2],true) --(TYPE,posX,posY,fromBlock) objAPI:createObj(blockID,(i2-1)*16,212-16*(i),0)
        elseif type(containing)=="table" then
            if containing.type=="event" then
                playStage:setEvent(containing.target,containing.value) --set event
            elseif containing.type=="switchclear" then
                playStage:setEvent("ploswitch",false)
                playStage:setEvent("plgswitch",false)
                playStage:setEvent("plrswitch",false)
                playStage:setEvent("plbswitch",false)
                playStage:setEvent("pswitch",false)
            end
        end
    end
    if blockIndex[ID].breakable==false or (mario.power==0 and not shell) then --create bumped block if unable to be destroyed
        local texture = blockIndex[ID].bumpable[2]
        if texture == true then texture = blockIndex[ID].texture[1] end
        objBumpedBlock:create(xLOC,yLOC,texture,blockIndex[ID].bumpable[3],false)
    else --smash the block
        playStage.SCORE=playStage.SCORE+50
        plot2place(0,xLOC,yLOC)
        objBrickParticleGlobalAnimIndex=0
        objAPI:createObj("brick_piece",pixelXY[1],pixelXY[2],false,-3,7.5) --top left
        objAPI:createObj("brick_piece",pixelXY[1]+8,pixelXY[2],false,3,7.5) --top right
        objAPI:createObj("brick_piece",pixelXY[1]+8,pixelXY[2]+8,false,3,2.5) --bottom right
        objAPI:createObj("brick_piece",pixelXY[1],pixelXY[2]+8,false,-3,2.5) --bottom left
        objAPI:addHitBox(nil,pixelXY[1]+1,pixelXY[2]-16,14,16,"block")
    end
    --CRASH on below line: line 2174 attempt to index field '?' (a nil value)
    if yLOC<=12 and blockIndex[plot2ID(xLOC,yLOC+1)].coin==true then --if there is a coin above the bumped block
        plot2place(0,xLOC,yLOC+1)
        objAPI:createObj("coin",pixelXY[1],pixelXY[2]-16,true)
    end
end --TODO rewrite needed ##############

function objAPI:checkFor(CHECK) --cannot be inside aggregatecheckx as has to display changes immediately, otherwise will be a frame late in some instances
    local X,Y,W,H,isMario,O=self.x,self.y,self.w or 16,self.h or 16,self.objectID=="mario",self.vy==0 and 0 or -1
    local function doCheck(x,y,isTop,side)
        if self.canCollectCoins and pixel2anything("coin",x,y,true) then
            objAPI:addStats("coins",1) pixel2place(0,x,y,true) objAPI:addStats("points",200)
        end
        if isMario then 
            if pixel2anything("damage",x,y,true) and (not (mario.starTimer>playStage.framesPassed)) then
                if ((self:gravityCheck(self.vy,true,true) and not isTop) or mario.vy==-0.61 or mario.vx~=0) then --inputs are so that if mario jumps on the pixel that the spike is, it will not hurt him unless he is walking/jumping into it.
                    mario:powerDownMario()
            end end
            if pixel2anything("kill",x,y,true) and (isTop or mario.vy<0) then --use isTop for when descending, so that mario sinks into lava slightly when in contact, rather than dying instantly on the surface. may look jank i guess but who cares that deeply about a calculator game anyway?
                mario:kill()
    end end end
    doCheck(X+2,Y+O,true,"L") doCheck(X+W-2,Y+O,true,"R") doCheck(X+4,Y+H,false,"L") doCheck(X+W-4,Y+H,false,"R")
    if isMario and mario.power>0 and (crouchCalc or not mario.crouch) then doCheck(X+2,Y-16+O,true) doCheck(X+W-3,Y-16+O,true) end
end --NEW code approved

--OTHER
function objAPI:type2class(TYPE)
    if typeIndex[string.sub(TYPE,1,5)]~=nil then
        return typeIndex[string.sub(TYPE,1,5)][1],typeIndex[string.sub(TYPE,1,5)][2]
    else return false,false
    end
end

function objAPI:type2name(TYPE,statusBox) --statusBox: 0=false, 1=true
    local name=""
    if type(TYPE)=="number" then
        if blockIndex[TYPE]~=nil then
            name=blockIndex[TYPE]["name"]
        end
    elseif string.sub(TYPE,1,4)=="warp" then
        local config=TYPE:split("_")
        local ID,action,option=config[2],config[3],config[4]
        if action=="edit" then name="EDIT WARP "..ID
        elseif option then name=nameIndex["warp_ID_"..action.."_"..option]
        else name=nameIndex["warp_ID_"..action]
        end
    elseif string.sub(TYPE,1,8)~="platform" then
        if nameIndex[TYPE]~=nil then name=nameIndex[TYPE] end
    else
        name={} --eg: platform_3~1~lx~64
        local config=(string.sub(TYPE,10,#TYPE)):split("~")
        if nameIndex[config[3]]~=nil then name[1]="Platform "..nameIndex[config[3]] end
        if statusBox==1 then 
            name[2]="Length: "..config[1]
            if string.sub(config[3],1,1)=="l" then name[3]="Distance: "..math.floor(config[4]/16) end
        end
    end return name
end

function objAPI:performLogic() --perform logic for the object, to be overridden by each object
    self:logic()
    if self.doMovements then
        if self.px and self.px ~=0 then self:aggregateCheckX(self.px,true) end
        if self.vx and self.vx ~=0 then self:aggregateCheckX(self.vx) end
        self:calculateAccelerationY(self.accelerationMultiplier or nil,self.terminalVelocity or nil)
        if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
        if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy) end
        self:setNewPushV() self:checkFor()
    end
end

function objAPI:apply(t1)
    table.apply(self,t1)
end