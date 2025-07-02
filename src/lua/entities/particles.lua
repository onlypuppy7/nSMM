--------------------------
-------BUMPED BLOCK------- OLD drawing format#################################################################
--------------------------
objBumpedBlock=class(objAPI)

    function objBumpedBlock:create(blockX,blockY,TYPE,replaceWith) --sorta forgot why i made this specifically have its own create function
        local objectID="bumpedBlock"..#entityLists.outer+#entityLists.inner+1+framesPassed+math.random(1,99999) --assign random ID
        table.insert(entityLists.outer,tostring(objectID))
        allEntities[objectID]=objBumpedBlock()
        allEntities[objectID].initObject=objAPI.initObject
        allEntities[objectID]:setup(objectID,blockX,blockY,TYPE,replaceWith)
        self.GLOBAL=true
    end

    function objBumpedBlock:setup(objectID,blockX,blockY,TYPE,replaceWith) --eg (23,6,"UsedBlock",false)
        local v,texture=plot2pixel(blockX,blockY),blockIndex[replaceWith]["texture"][1]
        if blockIndex[replaceWith]["theme"][plot2theme(blockX)]~=nil then texture=blockIndex[replaceWith]["theme"][plot2theme(blockX)][1] end
        self:initObject(objectID,texture,"outer",nil,{v[1],v[2]},true,0)
        self.yA=self.y
        self.replaceWith={blockX,blockY,ID2eventID(replaceWith)} --ID2eventID is mainly for the p-switch event. this single line probably wont work if you dont have two blocks that mirror each other
        self.interactSpring=false
        self.animCount=0 self.despawnable=true plot2place(99,blockX,blockY) --barrier
        self.disableStarPoints=true
    end

    function objBumpedBlock:logic()
        if self.animCount<3 then
            objAPI:sendToFront(self.objectID,self.LEVEL)
            objAPI:addHitBox(nil,self.x+1,self.y-16,14,16,"block")
        end
        if self.animCount<=4 then self.animCount=self.animCount+1
            self.yA=self.y-math.round(((math.sin((self.animCount*30)/57.296))*8),0) --math..?
        else self:destroy()
            plot2place(self.replaceWith[3],self.replaceWith[1],self.replaceWith[2])
        end
    end

    function objBumpedBlock:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs[TYPE],x,self.yA+8)
    end

--------------------------
-----BRICK PARTICLES------ OLD drawing format#################################################################
--------------------------
objBrickParticle=class(objAPI)

    function objBrickParticle:setup(objectID,posX,posY,TYPE,despawnable,thrustX,thrustY)
        self:initObject(objectID,TYPE,"particle",nil,{posX,posY},thrustX*0.4,math.abs(thrustY*8))
        self.THEME=(pixel2theme(self.x+1,true)==1) and "_underground" or (pixel2theme(self.x+1,true)==3) and "_castle" or ""
        self.animIndex=#entityLists.particle%4 self.delay=true self.status=((math.ceil((playStage.framesPassed/3)+self.animIndex))%4)+1
        self.xAnimTimer=playStage.framesPassed+15 self.GLOBAL=true self.interactSpring=false self.disableStarPoints=true
    end

    function objBrickParticle:logic()
    --ANIMATION (comes first in this case)
        self.status=((math.ceil((playStage.framesPassed/3)+self.animIndex))%4)+1
        if self.delay==true then self.delay=false return end --initial frame
    --X AXIS,Y AXIS
        if self.xAnimTimer>playStage.framesPassed then self.x=self.x+self.vx end
        if self.y>216 then self:destroy() return
        else self.vy=(self.vy<0) and (self.vy-0.6) or (self.vy<0.7) and -0.5 or self.vy*0.4
        end self.y=self.y-(self.vy*0.8)
    end

    function objBrickParticle:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs["brick_piece"..self.status..self.THEME],x,y)
    end
--------------------------
-----SCORE PARTICLES------ NEW drawing format(N/A)
--------------------------
objScoreParticle=class(objAPI)

    function objScoreParticle:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,arg1,"particle",nil,{posX-playStage.cameraOffset,posY+8},true,0)
        self.animLimit=sTimer(12) self.GLOBAL=true self.interactSpring=false self.disableStarPoints=true
    end

    function objScoreParticle:logic() 
        if gTimer(self.animLimit) then self:destroy()
        else self.y=self.y-3
    end end

    function objScoreParticle:draw(gc,x,y,TYPE,isEditor,isIcon)
        gc:drawImage(texs["score_"..TYPE],self.x,self.y)
    end
    
--------------------------
--------COIN ANIM--------- OLD drawing format#################################################################
--------------------------
objCoinAnim=class(objAPI)

    function objCoinAnim:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"outer",nil,{posX,posY},true,0) self.disableStarPoints=true
        self.yA=self.y self.status=1 self.animCount=0 objAPI:addStats("coins",1) self.interactSpring=false
    end

    function objCoinAnim:logic() 
        if self.animCount<16 then self.animCount=self.animCount+1
            self.yA=self.y-(math.sin((self.animCount*9)/57.296))*64
            self.status=((math.ceil((playStage.framesPassed/3)))%4)+1
        else self:destroy() objAPI:addStats("points",200,self.x,self.yA) end
        if self.animCount==16 then self.drawCondition=true end
    end

    function objCoinAnim:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not self.drawCondition then gc:drawImage(texs["coin_"..self.status],x,self.yA+8)
    end end