--------------------------
----FLAGPOLE FUNCTIONS---- NEW drawing format(ish)
--------------------------
objFlagpole=class(objAPI)

    function objFlagpole:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},0,0)
        self.despawnable=false self.my=0 self.interactSpring=false self.disableStarPoints=true
        local v=pixel2plot(self.x,self.y,true) plot2place(9,(v[1]+1),v[2]) --set hard block base
    end

    function objFlagpole:logic()
    end
    
    function objFlagpole:draw(gc,x,y,TYPE,isEditor,isIcon) --logic in draw so that it always runs...
        if isIcon then gc:drawImage(texs.flag,x,y)
        else
            gc:setColorRGB(121,202,16)
            gc:drawLine(x+7,y,x+7,y-1-(9*16))
            gc:drawLine(x+8,y,x+8,y-1-(9*16))
            gc:drawImage(texs.flagpole_top,x+4,y-8-(9*16))
            if not isEditor then
                if not gui.PROMPT then
                    if self.my==0 then
                        if not mario.clear then
                            local marioSize=(mario.power==0 or mario.crouch) and 0 or 16
                            if checkCollision(mario.x+1,mario.y-marioSize+1,14,14+marioSize,self.x+5,self.y-152,4,152) then --hit mario (side)
                                mario:clearedLevel({self.y-16,self.x-5})
                                self.my=4 mario.dir="R"
                                local height=self.y-(mario.y+16)
                                if     height>=128 then height="1up"
                                elseif height>=82  then height="2000"
                                elseif height>=58  then height="800"
                                elseif height>=18  then height="400"
                                else                    height="100" end
                                objAPI:addStats(height~="1up" and "points" or "1up",tonumber(height))
                                self.points=height
                        end end
                    else
                        if self.my<122 then self.my=self.my+4 --flag going down anim
                        elseif type(mario.clear)=="number" then --initiate walk-off
                            mario.clear={playStage.framesPassed+10} mario.dir="L" mario.x=mario.x+11
                end end end
                gc:drawImage(texs.flag,x-8,self.y+self.my+9-(9*16))
                if self.points then gc:drawImage(texs["score_"..self.points],x+11,self.y-self.my) end
            else
                gc:drawImage(texs.flag,x-8,y+1-(9*16))
                gc:drawImage(texs.HardBlock,x,y)
    end end end

--------------------------
----PLATFORM FUNCTIONS---- NEW drawing format(N/A)
--------------------------
objPlatform=class(objAPI)

    function objPlatform:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)  --platform_length~vel~MODE~distance eg, platform_3~2~lx~64
        local config=(string.sub(TYPE,10,#TYPE)):split("~")
        self.length,self.speed,self.ox,self.oy=config[1],config[2],0,0
        self:initObject(objectID,config[3],"outer",nil,{posX,posY},0,0)
        if self.TYPE=="lx" or self.TYPE=="ly" then --loops back and forth on the x/y axis
            self.distance=tonumber(config[4])
            if self.distance<0 then self.distance=math.abs(self.distance) self.speed=-self.speed end
            self.distanceTracker=self.distance
        elseif self.TYPE=="ru" or self.TYPE=="rd" then self.distanceTracker=0 end --repeats going up/down
        self.sort,self.mode=string.sub(self.TYPE,#self.TYPE,#self.TYPE),string.sub(self.TYPE,1,1)
        self.speed=(self.sort=="l" or self.sort=="d") and -math.abs(self.speed) or (self.sort=="r" or self.sort=="u") and math.abs(self.speed) or self.speed
        self.active=not (self.mode=="a" or self.mode=="f")
        self.despawnable=false self.interactSpring=false self.disableStarPoints=true
        self.GLOBAL=true --always drawn and logic applying, to reduce pop in
    end

    function objPlatform:logic() --handle both movement and animation
        if ((self.y<=-16) or( self.y>=204) or (self.x<=-(self.length*16)) or (self.x>=16*level.current.END)) and self.mode~="r" then objAPI:destroy(self.objectID,self.LEVEL) return end --despawn if needed
        self.x,self.y=self.x+self.vx,self.y-self.vy --move
        self.ox,self.oy=self.vx,self.vy
    --CHECK IF MARIO COLLIDED
        if not self.active then
            local pX,pY,marioSize=self.x,self.y+self.vy,(mario.power==0 or mario.crouch) and 0 or 16
            local pW,mX,mY=self.length*16,math.floor(mario.x+mario.px),math.floor(mario.y-mario.py)
            if ((mX+2>=pX and mX+2<=pX+pW) or (mX+13>=pX and mX+13<=pX+pW)) and mY+16==pY and mario.vy==0 then --mario is on platform
                self.active=true
        end end
    --PLATFORM MOVEMENT PATTERNS, UPDATE PLATFORM
        if self.mode=="l" then --LOOPING PLATFORMS
            if self.distanceTracker<0 then --loop back
                self.distanceTracker=self.distance self.speed=-self.speed self["v"..self.sort]=0
            else self.distanceTracker=self.distanceTracker-math.abs(self.speed)
                self["v"..self.sort]=self.speed
            end
        else
            local dir=(self.sort=="l" or self.sort=="r") and "x" or "y"
            if self.mode=="a" or self.mode=="f" then --ONE DIRECTION PLATFORMS
                if self.active then self.active=(self.mode=="f") and false or self.active
                    self["v"..dir]=self.speed
                else self["v"..dir]=0 end
            elseif self.mode=="r" then --REPEATING PLATFORMS
                self["v"..dir]=self.speed
                if self.y<=-18 and self.sort=="u" then      self.y=206
                elseif self.y>=206 and self.sort=="d" then  self.y=-18 end
        end end
        objAPI:addPlatform(self.objectID,self.x,self.y,self.length*16,self.vx,self.vy) --update the platform
    end

    function objPlatform:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not isEditor then
            for i=1,self.length do
                gc:drawImage(texs["platform"],x+(i-1)*16,y+self.oy)
            end
        else
            local params=(string.sub(TYPE,10,#TYPE)):split("~")
            local length,mode=params[1],params[3]
            length=isIcon and 1 or length
            for i=1,length do
                gc:drawImage(texs["platform"],x+(i-1)*16,y)
            end
            gc:drawImage(texs["icon_"..mode],x,y)--texs.icon_ru
            local plot=pixel2plot(x-editor.cameraOffset+16,y-8,true,true)
            local plotMouse=pixel2plot(mouse.x+editor.cameraOffset,mouse.y-8,true)
            if (editor.platformSelect and editor.platformSelect[3]==true and (plot[1]==editor.platformSelect[1] and plot[2]==editor.platformSelect[2])) or ((not (editor.platformSelect or editor.displayedGroup)) and plot[1]==plotMouse[1] and plot[2]==plotMouse[2]) then
                timer2rainbow(gc,framesPassed+200,10) gc:setPen("thin","dashed")
                local distance=tonumber(params[4])
                if mode=="lx" then
                    gc:drawRect(x+distance,y,length*16,8)
                    gc:drawLine(x,y+4,x+distance,y+4)
                elseif mode=="ly" then
                    gc:drawRect(x,y-distance,length*16,8)
                    local offset=(distance<0) and {8,0} or {0,8}
                    gc:drawLine(x+length*8,y+offset[1],x+length*8,y-distance+offset[2])
    end end end end

--------------------------
------EVENT FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objEvent=class(objAPI)

    --ok this is some bs. wtf is this? this is a class that just sets an event in the playStage.events table
    function objEvent:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",nil,{posX,posY},true,0)
        local eventDetails=TYPE:split("_")
        playStage.events[eventDetails[2]]=eventDetails[3]
        objAPI:destroy(objectID,"inner")
    end

    function objEvent:logic()
    end

    function objEvent:draw(gc,x,y,TYPE,isEditor,isIcon)
    end

--------------------------
-----SPRING FUNCTIONS----- NEW drawing format(N/A)
--------------------------
objSpring=class(objAPI)

    function objSpring:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},0,0)
        self.status=1 self.GLOBAL=true self.springData={}
        if self.TYPE=="spring_O" then     self.bounceHeight=16
        elseif self.TYPE=="spring_B" then self.bounceHeight=8
        elseif self.TYPE=="spring_R" then self.bounceHeight=24
        end self.boostHeight=self.bounceHeight*1.5
        self.disableStarPoints=true
    end

    function objSpring:logic() --handle both movement and animation
        -- self.status=((math.ceil((playStage.framesPassed/4)))%3)+1
        -- self:checkMarioCollision({"clear",self.animType},true)
        local function check(entity)
            if not entity.spring and entity.interactSpring and checkCollision(entity.x+1,entity.y+1,(entity.w or 16)-2,16,self.x+1,self.y,15,1) and (entity.vy<0 or entity.py<0 or self.py>0 or self.vy>0) then
                entity.y=self.y-12 self.status=2 table.insert(self.springData,{0,entity,entity.vx,self.bounceHeight,self.boostHeight}) entity.vx=0
        end end
        local function checkLists()
            for k in pairs(entityLists) do --do all entity lists
                local focusedList=entityLists[k]
                for i=1,#focusedList do --for all entities within the list
                    local entity=allEntities[focusedList[i]]
                    check(entity)
        end end end
        checkLists() check(mario)
        for i=#self.springData,1,-1 do
            local springData=self.springData[i]
            local entity=springData[2]
            springData[1]=springData[1]+1
            if springData[1]==2        then self.status=3 entity.vy=0 entity.spring=true --fixes softlock when mario has cleared a level while bouncing on springs
            elseif springData[1]==4    then self.status=2
                entity.vy=(entity.objectID=="mario" and input.stor.up>-8) and springData[5] or springData[4]
                entity.vx=entity.objectID=="mario" and 0 or springData[3]
                entity.spring=false
            elseif springData[1]==6    then self.status=1 table.remove(self.springData,i)
            end
            if entity.spring then entity.y=(self.status==3 and self.y-7) or (self.status==2 and self.y-12) or self.y-16 end
        end
        -- for i=1,#self.removeEntities do table.remove(self.springData,self.removeEntities[i]) end
        self:aggregateCheckX(self.px,true)
        self:aggregateCheckX(self.vx)
        self:calculateAccelerationY()
        if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
        if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy) end
        self:setNewPushV() self:checkFor()
    end

    function objSpring:hit(circumstance)
        if self.vy<=0 and circumstance=="block" then
            self.vy=6
    end end

    function objSpring:draw(gc,x,y,TYPE,isEditor,isIcon)
        local status=self.status or 1
        local offset=(status==2) and 4 or (status==3) and 9 or 0
        gc:drawImage(texs[TYPE.."_"..status],x,y+offset)
    end

--------------------------
----FIREBALL FUNCTIONS---- OLD drawing format#################################################################
--------------------------
objFireball=class(objAPI)

    function objFireball:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"particle",nil,{posX,posY,8,8},TYPE=="fireball_L" and -6 or 6,-0.5)
        self.timer=false self.despawnable=true self.status=((math.ceil((framesPassed/2)))%4)+1
        self.doesBounce=7 self.isFireball=true self.disableStarPoints=true self.interactSpring=false
    end

    function objFireball:handleFireballHit()
        self.dead=true self.timer=1
        self.x,self.y=self.x-4,self.y-4
        self.TYPE="fireball_A"
        self.status=1
    end

    function objFireball:logic()
        if not self.dead then
            objAPI:addHitBox(self.objectID,self.x,self.y,12,12,"fireball")
    --X AXIS, Y AXIS + PLATFORMS
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY(0.85)
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
    --DEAD
        else self.timer=self.timer+1
            if self.timer>=(flashingDelay*3)+1 then objAPI:destroy(self.objectID,self.LEVEL) return
        end end
    --ANIMATION
        if not self.dead then self.status=((math.ceil((playStage.framesPassed/2)))%4)+1
        else self.status=math.ceil(self.timer/flashingDelay)
        end
    end

    function objFireball:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[self.TYPE..self.status],x,y)
    end

--------------------------
-----MULTICOIN BLOCK------ NEW drawing format(N/A)
--------------------------
objMultiCoinBlock=class(objAPI)
        
    function objMultiCoinBlock:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"background",nil,{posX,posY},true,0)
        self.despawnable=false self.GLOBAL=true self.timer=sTimer(100) self.interactSpring=false self.disableStarPoints=true
        objAPI:createObj("coin",self.x,self.y,true)
    end

    function objMultiCoinBlock:logic()
        if cTimer(self.timer)<=0 then objAPI:destroy(self.objectID,self.LEVEL)
        elseif cTimer(self.timer)==1 then --start ending the multi coin period
            local config=self.TYPE:split("_")
            if (pixel2ID(self.x+16,self.y,true)~=99) then pixel2place(tonumber(config[2]),self.x+16,self.y,true) end --get rid of the infinite coin block at all costs
            for i=1,#entityLists.outer do --now THIS is a stupid workaround to a problem i caused, finds the bumped block animation and changes what it replaces
                local objectID=entityLists.outer[i]
                if string.sub(objectID,1,11)=="bumpedBlock" and allEntities[objectID].x==self.x and allEntities[objectID].y==self.y then
                    allEntities[objectID].replaceWith[3]=tonumber(config[2])
    end end end end

    function objMultiCoinBlock:draw(gc,x,y,TYPE,isEditor,isIcon) end -- ...nothing to draw