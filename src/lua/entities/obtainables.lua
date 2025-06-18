--------------------------
------ORB FUNCTIONS------- NEW drawing format
--------------------------
objMagicOrb=class(objAPI)

    function objMagicOrb:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},0,0)
        self.status=1 self.GLOBAL=true self.animTimer=0 self.isBouncy=true self.allowStarCollision=true
        local v=self.TYPE:split("_")
        self.animType=(v[2]=="a0") self.moveType=(v[3]=="m1") --i think the animtype is reversed, just roll with it tbh
        self.interactSpring=self.moveType self.disableStarPoints=true
    end

    function objMagicOrb:logic() --handle both movement and animation
        if not self.dead then
            self:checkMarioCollision({"clear",self.animType},true)
            if self.moveType then
                self:aggregateCheckX(self.px,true)
                self:aggregateCheckX(self.vx)
                self:calculateAccelerationY()
                if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py) end
                if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
                self:setNewPushV() self:checkFor()
    end end end

    function objMagicOrb:hit()
    end

    function objMagicOrb:draw(gc,x,y,TYPE,isEditor,isIcon)
        if not isEditor then
            local texture=self.dead and "poof_" or "magicorb_"
            if self.dead then
                if not gui.PROMPT then
                    self.animTimer=self.animTimer+1
                    self.status=((math.ceil((self.animTimer/5)))%5)+1
                    if self.animTimer>=20 then objAPI:destroy(self.objectID,self.LEVEL) playStage.wait=false end
                end
            else
                self.status=((math.ceil((playStage.framesPassed/4)))%4)+1
                if self.status==4 then self.status=2 end
            end
            if self.status~=5 then gc:drawImage(texs[texture..self.status],x,y) end
        else
            local v,status=TYPE:split("_"),((math.ceil((framesPassed/(8*flashingDelay))))%2)+1
            v=(status==1) and v[2] or v[3]
            gc:drawImage(texs.magicorb_1,x,y)
            gc:drawImage(texs["icon_"..v],x,y)
        end
    end

--------------------------
----POWER-UP FUNCTIONS---- OLD drawing format#################################################################
--------------------------
objPowerUp=class(objAPI)

    function objPowerUp:setup(objectID,posX,posY,TYPE,despawnable,arg1,arg2) --eg ("mushroom37253",64,16,"mushroom",true)
        self:initObject(objectID,TYPE,"inner",{16,16,false,false},{posX,posY},true,0)
        if string.sub(TYPE,1,1)=="P" then
            if mario.power==0 then self.TYPE="mushroom"
            elseif mario.power>0 then self.TYPE="fireflower" end
        end self.disableStarPoints=true
        self.status=(self.TYPE=="mushroom" or self.TYPE=="mushroom1up") and "" or 1
        self.despawnable=despawnable
        if despawnable==true then self.blockTimer=playStage.framesPassed+(4-1) self.y=self.y-4
        else self.blockTimer=playStage.framesPassed end
        self.vx=(self.TYPE=="fireflower") and 0 or (level.current.allowBidirectionalSpawning==true and (mario.x<self.x)) and -2 or 2
        self.doesBounce=(self.TYPE=="star") self.turnAround=true self.allowStarCollision=true
    end

    function objPowerUp:use() objAPI:destroy(self.objectID,self.LEVEL)
        if self.TYPE=="mushroom1up" then objAPI:addStats("1up",1,self.x,self.y)
        else    if self.TYPE=="mushroom" then       mario:powerUpMario(1)
                elseif self.TYPE=="fireflower" then mario:powerUpMario(2)
                elseif self.TYPE=="star" then       mario:powerStarMario()
                end objAPI:addStats("points",1000,self.x,self.y) end
    end

    function objPowerUp:logic() --handle both movement and animation
        if self.blockTimer<playStage.framesPassed then
    --MARIO COLLISION, X AXIS, Y AXIS + PLATFORMS
            self:checkStuckInWall()
            self:checkMarioCollision({"powerup"},true)
            self:aggregateCheckX(self.px,true)
            self:aggregateCheckX(self.vx)
            self:calculateAccelerationY()
            if self.py<=0 then self:gravityCheck(-self.py,true) else self:bumpCheck(-self.py)      end
            if self.vy<=0 then self:gravityCheck(-self.vy)      else self:bumpCheck(-self.vy)      end
            self:setNewPushV() self:checkFor()
    --ANIMATION
        else self.y=self.y-4 --rise from block
        end
        if self.TYPE=="fireflower" or self.TYPE=="star" then
            self.status=((math.ceil((playStage.framesPassed/flashingDelay)))%4)+1
    end end

    function objPowerUp:hit(circumstance)
        if self.blockTimer<playStage.framesPassed then
            if (circumstance=="block" and self.vy<=0) or (level.current.enablePowerUpBouncing and circumstance~="block") then
                self.vy=10
    end end end

    function objPowerUp:draw(gc,x,y,TYPE,isEditor,isIcon)
        local status=self.status or (TYPE=="fireflower" or TYPE=="star") and "1" or ""
        gc:drawImage(texs[TYPE..status],x,y)
    end